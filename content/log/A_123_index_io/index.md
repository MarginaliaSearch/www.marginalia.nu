---
title: Faster Index I/O with NVMe SSDs
date: 2025-08-16
tags:
  - search-engine
  - nlnet
---
The Marginalia Search index has been largely rewritten to perform much better, using new data structures designed to make better use of modern hardware.  This post will cover the new design, and will also touch upon some of the unexpected and unintuitive performance characteristics of NVMe SSDs when it comes to read sizes.

The index is already fairly large, but can sometimes feel smaller than it is, and paradoxically, query performance is a big part of why.  If each query has a budget of 100-250ms, a design that finds and ranks results faster in that time period will produce better search results.   There are other limitations as well, query understanding is still somewhat limited, where only minor changes to a query can unearth dozens of new related results.

The index redesign has been necessitated due to recent and upcoming changes.  As part of incorporating the new advertisement detection algorithm, the limits and filtering conditions on the indexed documents have been relaxed considerably, and the index has grown from 350,000,000 documents to 800,000,000.  

The next task is indexing results in additional languages, which is also likely to grow the index considerably.  

A write-up is in the pipeline that will provide more details about the advertisement detection system, which is code complete but waiting for more data to trickle in.  Since data-gathering began in May, only about 60% of the domains have been analyzed, so the results are still somewhat incomplete and the results likewise patchy.  Here is a [teaser](https://marginalia-search.com/site/themindlessphilosopher.wordpress.com?view=traffic) if anyone is eager for a sneak preview.

## Indexing at a glance

At a very high level you can think of the search engine's data structures like the C++-like code below.  Boxes and arrows will just bring in additional details that add no relevant understanding and just makes this more confusing, in this case code is much easier to reason about.  Just keep in the back of your mind this is just an analogy, and these are actually files on disk.

```c++
map<term_id, 
    list<pair<document_id, positions_idx>>
   > inverted_index; 

list<positions> positions;
```

The data structures can be viewed as effectively immutable, which means we can ignore many concerns regarding concurrent mutation that haunt traditional DBMS-related work.

For the purposes of this blog post, a query can be understood to work like this:

1. The documents lists of each term in the query are intersected
2. For each document containing all terms, positions are retrieved
3. The document IDs and their associated position are used to rank the documents
4. The best N results are returned

The `inverted_index`  structure has been implemented as a memory-mapped B-tree.  There are compelling arguments why this is a bad idea gathered in the paper [Are You Sure You Want to Use MMAP in Your Database Management System?](https://db.cs.cmu.edu/mmap-cidr2022/)   While known, this has mostly been ignored in the name of solving one problem at a time. 

### Aside: Read Modes

*If you have already read `open(2)`, you can skim through this part.* 

In Linux, you can read files in two modes:

**Buffered reads** go through the system's page cache to (hopefully) avoid reading any data at all from disk.  If the data is not cached, an actual read is executed.  Buffered reads can often read more data than what is requested, and/or read forward a bit. 

**Direct reads** (a.k.a. O_DIRECT) do not consult the system cache, and copy the data directly to your buffer.  Linus Torvalds famously [thinks this interface has its limitations](https://yarchive.net/comp/linux/o_direct.html).

Buffered reads are *usually* what you want, but the one exception is when you are doing database-adjacent development, and typically have extremely random access patterns in files with sizes that exceed the system RAM.  We're unfortunately in the second camp, and here managing your own buffer pool and using direct reads is often favorable. 

The readahead in buffered reads is also undesired with random access patterns as it drives up the I/O with very small chances of beneficial outcomes, but this is thankfully at least somewhat configurable via the `fadvise` call, and not a major reason to avoid them.

Direct reads have a few caveats, the biggest one being that they in practice will only permit reads of some block-size bytes at multiples of that block-size offsets.  Actually finding out what that block size is, is enough work that there's a whole section about it in the [open(2) man page](https://man7.org/linux/man-pages/man2/open.2.html#:~:text=STATX_DIOALIGN), but it's often either 512B or 4096B.

With no experience in the matter, this may seem like direct mode would be much slower, to read e.g. 4096B if you are after 120B, but buffered reads *also* read data in chunks like these, regardless of how much you need.   Direct reads are generally somewhat faster in the event of a cache miss since the data doesn't need to be copied between buffers, and in general have more consistent latencies.  Buffered reads can also slow down due to page cache thrashing.

There is a change coming to Linux in `RWF_DONTCACHE`  (originally `RWF_UNCACHED`) which seems a promising middle-ground between buffered and direct modes, but unfortunately support seems a bit spotty still at this point.  There's an interesting discussion on the rationale behind [RWF_DONTCACHE/RWF_UNCACHED on lwn](https://lwn.net/Articles/806980/).  
  

## Redesigning The B-Trees

The first optimization was to re-implement the existing B-tree structure using direct-mode reads instead.  This was a bit finicky but not more than a few days' work.  Unfortunately this wasn't very fast, and to make matters worse, the on-disk size of the documents lists grew significantly due to the block-size limitations.

A large part of the problem was that the B-trees were designed around implicit pointers, which meant that all nodes needed to be block aligned, which led to considerable dead air in the data structure, as few document lists were cooperative enough to be a neat multiple of 256 items in length.

The B-trees could probably have been fixed with some effort, but as it will turn out it was good much effort was not put toward this, instead, a different structure was implemented: A deterministic block-based skip list.  It was also not all a waste, as one salvageable component that fell out from the b-tree development was a buffer pool that generally performs pretty well.  

## Deterministic Block Skip Lists

Skip-lists are traditionally used in search engines and really shine when it comes to sorted list intersection tasks.  Skip lists give you roughly the same characteristics as a B-tree and are indeed closely related structures that are optimized for list intersection, and are above all much easier to implement.  

A text-book implementation of a skip list is a linked list, with a number of values associated with each node, and a random number of forward pointers that permits the reader to skip ahead in the list beyond the next node. 

Readers will have to make do with another piece of C-like pseudocode as an illustration for the structure, as any attempts to draw it with boxes and arrows ends up looking like a jumble of porcupines.  As a reminder, this is still on disk.

```c
struct node {
  // header
  int size;
  short flags;  // signals if this is the last block
  
  short forwardPointerCount;
  long forwardPointerMaxValues[forwardPointerCount];
  
  long document_ids[size];
  long position_indexes[size];  
}
```

Conceptually there is some B+-tree DNA in this structure, but it is not a search tree but generalized to a directed acyclic graph.  Due to the large connectivity between each node, it is also very unsuitable for mutable datasets, as you would have to lock down almost the entire data structure in order to make changes to it. 

In order to make this both dense and direct-mode friendly, we'll impose a few rules.

* The first node in a list may be anywhere in a block.
* All subsequent nodes must only start at a block boundary.
* A node must never straddle a block boundary. 

This allows for truncated blocks, while ensuring no blocks requires a misaligned read.

Truncated blocks are important, as 90% of all pareto distributions appear in the 10% of all problems that are relevant to search engines.  Some keywords have few (even single) documents associated with them, others have tens of millions.

The rules above also permit the forward pointer locations to be deterministic. Their destinations can be inferred from the current position alone, so that we only need to store the largest value in the corresponding node in order to determine which block to visit next.  

This, combined with relatively large block sizes, means we can be generous with the forward pointers, so that when traversing the structure having to backpedal and take another branch in order to go forward is never necessary:  You can always find an efficient path from the current block to the one you want by pressing on.  

Tree structures typically optimize the traversal time from root to leaf for a single key, but what we're interested in is finding all relevant blocks for a list of sorted keys, and in that scenario, constantly climbing up and down branches can quickly become inefficient. 

The forward pointers follow a scheme that is linear for the first few pointers, and then quadratic, landing at a maximum forward stride of about 8 million document IDs, acknowledging the fact that we are intersecting sorted lists, and that small jumps forward are more likely than large ones, while still permitting larger leaps when it is necessary.

## Performance

To evaluate the performance of these changes, two benchmarks are used revolving around the same query:  "to be or not to be".

This is a real torture test that stresses every aspect of the index.  

1. The lookup stage, that intersects documents lists is well exercised because the words "to", "be", "or", and "not" appears in an absurd number of documents.

2. The preparatory stage that retrieve positions lists is exercised by the fact that the positions lists are unusually long since the words are common and appear numerous times in each document.

3. The ranking code has to rank the numerous intersections that are found.

The **lookup** test attempts to locate every intersection of the words, but does not rank them.  This is an exhaustive search, where all intersections are considered.  The benchmark measures how long this takes.

The **execution** test finds and ranks as many intersections as it can in a 150ms time window.  The benchmark measures how many results are ranked per second.

This test would sadly not say much about the memory-mapped structures used before, since especially given they are implemented in Java, they are effectively impossible to meaningfully benchmark, as mmap gets unrealistically fast with repeated access, and Java needs repeated access in order for the C2 JIT compiler to kick in and make the code fast.

The new code is at least somewhat benchmarkable, since the mmap lookups are gone.  There's still the matter of the page cache speeding up certain buffered reads, but that is a fairly realistic scenario, as the files that are being read are typically relatively small and likely to end up in the page cache in a real-world scenario.   Switching to direct mode reads is an option, but in this discussion buffered reads are used unless otherwise specified.  In general unbuffered reads approximately halve the benchmark numbers.

### NVMe SSDs

Modern enterprise NVMe SSDs are very fast, and in many ways feel like sci-fi technology when you actually lean into their idiosyncrasies.

In isolation, almost no matter how much data you ask it to read it takes roughly the same amount of time.  This flies in the face of a lot of assumptions about storage you might have, if you are familiar with mechanical drives or SATA devices.

This is a simple benchmark on a Samsung PM9A1 on a with a theoretical maximum transfer rate of 3.5 GB/s.  The benchmark is a piece of code that repeatedly issues a direct-mode `pread()` of various block sizes at random locations. 

It should be noted that this is a sub-optimal setup that is less powerful than what the PM9A1 is capable of due to running on a downgraded PCIe link.  These sorts of benchmarks are also fairly hardware-dependent.  While NVMe SSDs are generally similar, they are not all identical.

Caveats aside, the results are still loud and clear.  

| Block Size | Transfer Rate | Avg Time  |
| ---------- | ------------- | --------- |
| 512 B      | 6.2 MB/s      | 73 us/op  |
| 1 KB       | 13.3 MB/s     | 73 us/op  |
| 2 KB       | 26.7 MB/s     | 73 us/op  |
| 4 KB       | 52.9 MB/s     | 73 us/op  |
| 8 KB       | 99.6 MB/s     | 78 us/op  |
| 16 KB      | 174.4 MB/s    | 89 us/op  |
| 32 KB      | 384.4 MB/s    | 91 us/op  |
| 64 KB      | 601.4 MB/s    | 103 us/op |
| 128 KB     | 1.0 GB/s      | 120 us/op |
| 256 KB     | 1.7 GB/s      | 141 us/op |
| 512 KB     | 2.4 GB/s      | 206 us/op |
| 1 MB       | 3.1 GB/s      | 314 us/op |


Up to very large block sizes, read time as a function of block size is a sublogarithmic function for isolated single reads!

Or in other words, if it takes twice as long to read 256 KB as it does 512 B, why would you ever read 512 B? 

A counter argument might be that this drives massive read amplification, what if you are only interested in a handful of bytes from that 256 KB block you read.  Wouldn't that be bad, or wasteful?  As it turns out, not really, or at least not always.   

You can absolutely go overboard and drown the controller in humongous read commands, and if you're performing many concurrent reads all in one go, this will deteriorate the performance, but for pointer chasing like we are doing when navigating a search structure, where we read one or a handful of blocks at a time, this is not a concern at all.  If you are actually consuming the data you are reading, the read-rate is limited and the scenario can generally be avoided.

Initially the block size selected was 4096 because a nice round number had to be picked.  This initial ansatz was a mistake that, if the benchmark results in the table above are fully representative, gave the index access to less than 1% of the read performance of the SSD being used.   

Since the task does more than just perform reads, and not all of the index data that is read is a relevant search result, the actual difference is less dramatic than the predicted 100x, but it's still quite significant especially when comparing a small block size like 4KB with the larger ones.

Running the "to be or not to be"-benchmarks, the difference between block sizes look like this.

| Block Size | Lookup | Execution   |
| ---------- | ------ | ----------- |
| 4 KB*      | 0.600s | 490,000 r/s |
| 32 KB      | 0.188s | 780,000 r/s |
| 128 KB     | 0.160s | 890,000 r/s |
| 1 MB       | 0.149s | 820,000 r/s |

\* The forward pointer scheme was adjusted here to become quadratic sooner than with larger block sizes, reflecting increased odds of larger jumps. 

128 KB appears a point of diminishing returns, larger block sizes yield similar or worse performance.   The fact that lookup figures improve past this point, but execution figures begin to deteriorate for larger block sizes can likely be explained by how the execution test is more sensitive to how fast the lookup code begins to deliver results to the ranking code, a time that increases with larger block sizes.

The plan up to this point was to eventually add compression to the document lists blocks, though it's looking increasingly questionable whether that is a good idea:  The search engine is simply not limited by how fast it can read document lists off disk with this design, result ranking and in particular the retrieval of position data is the biggest bottleneck.

It is possible compression could still be worthwhile if the ranking consisted only of a simple TF-IDF calculation instead of the exact term position logic involved.

These huge blocks also mean we can add a significant number of forward pointers to each block, all but guaranteeing we can find the appropriate block for any given document ID in a single-digit number of node traversals regardless of which node the search starts at. 

Another benefit of larger blocks is that the buffer pool performs better, as the access pattern changes from many mutations of a large table, to fewer mutations of a small one. 

### I/O contention and latency

At this point the index was fast, but the search engine was suffering from very inconsistent request times.  The search engine is tasked with not merely ranking many documents and finding the best, but doing so in a timely manner.  

A major source of latency was [io_uring](https://unixism.net/loti/), which was also adapted as part of this performance tuning work. The index lookups themselves are a poor candidate for io_uring since it's a random pointer traversal, though the search engine performs other disk reads which are far better candidates.

The ranking system needs to retrieve position data for each search term in the query in each document being ranked. These are many small reads, and doing them sequentially is quite slow.  io_uring is somewhere between 5 and 20x faster for these workloads, though admittedly, significant performance gains can also be found via conventional thread-based concurrency.

Here io_uring was used to create a sort of `pread()` shotgun where multiple reads were dispatched simultaneously.  A drawback with this approach is that it's very easy to create a thundering herd with dozens of ranking threads performing read-batches each containing hundreds of read instructions all spinning up at once and clobbering the poor SSD controller relentlessly.   This was not a problem with the original design where each thread was doing synchronous reads.

The command queue clobbering was in part mitigated by breaking out the position data retrieval into a limited number of separate threads, instead of doing it in the numerous ranking threads.  Having position retrieval and lookup running concurrently like this is still causing some degree of I/O contention, but the resulting latency penalty is manageable and the overall increase in throughput is still worth it. 

io_uring *can* deal with reads independently as they finish, this is arguably the idiomatic way of using it, and an attempt was also made to implement a streaming approach to async reads in this manner, which worked well enough, but ended up deteriorating performance despite increasing the activity of the drive.  The deterioration was likely because it left so little breathing room that the positions retrieval slowed down the index lookups, as the lookups began taking a significantly longer time to finish.  

Because the benchmark has a fairly short iteration time of about a quarter of a second, with a wind-up period, followed by an intense burst of activity, and then a wind-down and reset phase, tools like iostat are likely to under-report the actual disk usage despite showing considerable queue depth, utilization and IOPS. 

Finding a good balance requires a fair bit of tuning.  The command queue doesn't need to be *empty*, this is still an NVMe SSD we're talking about and they are famously pretty good at dealing with higher queue depths, but as the queue grows read-times start to become increasingly jittery and especially when using io_uring to dispatch many reads at the same time, this jitter can be magnified into pauses of dozens of milliseconds.   The search engine typically has an execution budget of up to 150ms for API queries.  Pausing for 30ms to wait for I/O isn't great under those constraints.  

### Data Locality

Another optimization late in the process was to re-arrange the locations of the positions data.  These were previously written sequentially to a file by multiple concurrent writers, meaning that positions from the same document ended up separated by longer distances than necessary.  

Redesigning the writers to in best effort cluster the positions lists by document reduced this spread and meant that more relevant data could be acquired in fewer reads.  

Clustering the data like this works especially well when using buffered reads with `POSIX_FADV_RANDOM`, which have outperformed O_DIRECT reads for these tasks when evaluating the performance in production after deployment.  This is to be expected, as it lets the kernel merge read requests where appropriate.

Linux I/O schedulers should also be mentioned in the context of high I/O pressure.  Typically NVMe SSDs run without a scheduler, as the controller does a good enough job of dealing with high queue depths that it doesn't matter.  In theory I/O schedulers can rearrange and merge read requests, making better use of the hardware, though this is less likely on an NVMe SSD.  `mq-deadline` was briefly evaluated, but didn't significantly improve the latency numbers or throughput.   
##  Conclusions

If performance is to improve further, more optimizations in this vein will be necessary.  The current bottleneck seems to be in IOPS.  It's possible a better compression algorithm for positions data could be found.  Right now they are delta-encoded and stored as varints, which is a significant compression, but there is room for improvement.  

Originally the search engine relied on bloom filter intersection to do approximate position matching instead of exact position matching.  It's possible reviving this technique to some extent could help with reducing the number of position retrievals needed.

Squeezing the most performance out of NVMe SSDs requires a fair bit of benchmarking, and old assumptions need to be scrutinized.  It's mind-boggling how you can read 1 MB in the same time as four sequential 1 KB read operations.  

Getting the most of these devices often has more to do with data locality, read-merging and queue depth than limiting the number of bytes read.  

At the same time, benchmarking anything that has to do with disk I/O is incredibly difficult.  You always need to understand what you are benchmarking and know how to interpret the numbers.  It is very easy to create unrealistic scenarios so that you end up benchmarking the wrong thing.  I/O is layers and layers of caches.  Applications do caching, the OS does caching, the storage device sometimes does caching as well.  

`io_uring` is a tricky one and can easily turn into a foot gun that does more harm than good when used for disk reads. Admittedly the shotgun approach employed in the positions reads is not quite how you are supposed to use it, but for the constraints of the application seems to produce the best balance of throughput and latency, in part because the feast-to-famine cycles introduces breathing room for the drive to process other commands as well.

These changes are all merged into master and deployed in production, and after some minor teething issues seem to be working fairly well.  128 KB block sizes are used for the production deployment, though values between 64 KB and 256 KB seem to perform roughly comparably.

The new index is designed to make the most use of NVMe SSDs, but as it's intended to possible to run on a variety of hardware, a lot of it is configurable, and for example disabling io_uring and reducing block sizes should make it operate reasonably well even on SATA SSDs.

Check out the links below if you found this even remotely interesting.  They're dig much deeper into the same sorts of topics.
## Further Reading

* [Reading from External Memory](https://arxiv.org/pdf/2102.11198) - Ruslan Savchenko
* [Achieving 11M IOPS & 66 GiB/s IO on a Single ThreadRipper Workstation](https://tanelpoder.com/posts/11m-iops-with-10-ssds-on-amd-threadripper-pro-workstation/) - Tanel Poder
* [Are You Sure You Want to Use MMAP in Your Database Management System?](https://db.cs.cmu.edu/mmap-cidr2022/) - Crotty, Andrew and Leis, Viktor and Pavlo, Andrew.