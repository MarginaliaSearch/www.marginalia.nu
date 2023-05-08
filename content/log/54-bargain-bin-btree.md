+++
title = "The Bargain Bin B-Tree"
date = 2022-04-07
section = "blog"
aliases = ["/log/54-bargain-bin-btree.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I've been working lately on a bit of an overhaul of how the search engine does indexing. How it indexes its indices. "Index" is a bit of an overloaded term here, and it's not the first that will crop up. 

Let's start from the beginning and build up and examine the problem of searching for a number in a list of numbers. You have a long list of numbers, let's sort them because why not. 

I will print a short list of numbers, but extend it in your mind.

```
  1 3 4 5 7 9 10 14 16 17 18 20 21 27 28
```

You're tasked with finding whether 20 is a member of this list. The simplest solution is to go over it one by one, as a linear search. 

This is fine if the list is short, but our list is unimaginably long. Think at least 15 megabytes, not 15 items. We want finding these items to be blazingly fast, too. People are waiting for search results page to load. Can't spend 20 minutes checking every item on the list.

This list actually indexes itself. The next step from a linear search is to use a binary search. Any sorted list implicitly forms a search tree structure. 

Check the middle item, [14], is that smaller or larger than 20? It's smaller. Check the item in the middle between 14 and 28? Well what do you know, that's [28]. A hit in two tests. 

The worst case for a list of 15 items is four tests, the average is about three, or rather, approximately log2(N-1). This is pretty great when dealing with RAM. Even for 15 megabytes, the expected number of tests is only 24. The distribution is skewed very heavily toward this value, with a 75% chance to get 24 or 25 tests. Even 150 gigabytes you get just 38 tests. Memory reads are very fast, so this is pretty sweet! Mission accomplished! 

## SSDs

Now, if the list is 150 gigabytes, we probably can't keep it in memory. We must keep it on disk instead. No worry, you might think. SSDs are great, they have good random access performance! That's a statement that should come with an asterisk of the sort you find after "free magazine subscription".

Programming for SSDs is complicated, and on top of that, there's what the SSDs themselves do, what the SSD controller does, what the SATA protocol does, what the operating system does, what the programming language does. All these factors affect how much juice you get when you squeeze. 

For most tasks it doesn't matter, you can treat SSD reads as effectively free. A search engine index isn't most tasks, however. It's a weird niche of a task that breaks the mold even for most traditional DBMS approaches. 

Practically speaking, we can imagine that SSDs read and write data in chunks. The size is device specific and pretty hard to actually find out, but 4096 bytes is a good guess as even if it's wrong, it aligns up with the page size of the operating system, which is another thing we really need to align ourselves with if we want to go fast.

What you need to know is that when you tell your operating system to go read a byte off a memory mapped SSD, you will get a 4K page of data. The OS may decide to read more than that, but it won't read less. The same when you write, except this time it's the SSD hardware that is forcing each write to be exactly one block. It tries to pool and gather writes but that's not always possible. Bottom line is that sequential I/O is fast, the more random and small the I/O is, the worse things get. You don't need to wait for the seek like you do with mechanical hard drives, but that doesn't mean random I/O is free like in RAM.

There is a name for this phenomenon: I/O amplification. There are multiple sources of I/O amplification, from the hardware, from the operating system, from the algorithm you're using. It's a measure of how much work is done relative the the minimal work task. If a task to insert 1 byte in the middle of an array list means you have to shift 40,000,000 bytes to the right in that list, the write amplification is 40 million. If you want to find 1 byte from a linked list and you have to go through 25,000,000 bytes worth of nodes to get it, then the read amplification is 25 million.

The operating system reads and caches the surrounding data in case you might need it. If you read one byte, you read it from disk, and then you go to read the byte next to it, you're reading from memory and not from disk, which is so much faster it may as well be considered free.

If you are reading scattered bytes off an SSD, like you would during a binary search, you're going to cause dozens of these page faults, that is, the operating system will actually have to go fetch the bytes rather than read from its cache; and not only those bytes, but the blocks they belong to.

It is much much much slower to read from a disk than from main memory, so the performance of a disk based index can be measured in how may pages it touches. The bad news is that our binary search touches a lot of them. Our 38 tests from before is roughly equivalent to touching 28 pages. Even though we're only looking at 38 positions in the index file (a total of 304 bytes), we're causing the operating system to to have to read something like 11 Kb of data. Ouch.

There must be a better way.

## The Bargain Bin B-Tree

If we lean into the reality of reading data within 4K pages being cheap to the point of nearly being free, then we can create a tree structure based on 4K pages. You'd normally go for a proper B-tree or a LST-tree, but since this is a static index with no real-time updates, we can for something a bit stupider.  

The search engine uses 64 bit words for these indexes. Each 4K page fits 512 words. 

Let's build an implicit B-tree with branching factor 512. This is balanced search tree of height Θ(1+log512(N)), where each node is a sorted list of numbers implicitly indexing the children of the node. I'll spare you the details of the implementation.

This data structure is like a conventional B-tree's provincial cousin, disregarding any concern for inserts or data mutation for the sake of reducing the index size. I will admit, I don't know what this data structure is called. It's simple in so many ways it may not even have a name. I can imagine Donald Knuth looked at it, furrowed his brows, and brushed it off into the garbage like stray pencil shavings. 

I'm tentatively calling it The Bargain Bin B-Tree until someone tells me it has an established name. 

Before we dismiss it, let's never the less see how it performs. At first glance each look-up touches exactly 2+log512(N) pages. We can reduce those 28 average page reads from the binary search to 6 guaranteed page reads in every case. This is a decent start.

But wait, there's more! The physical size of this index is a fraction over 1/512 that of the original data for large data volumes. The index is only about 300 Mb if our data-to-be-indexed is 150 gigabytes! 

We can easily fit the entire tree neatly in memory, and then we only ever need to do a single disk read to find our needle. Only if the data creeps into the terabytes, we may need to start looking at two reads per look-up. 

Huh!

This is pretty good, as long as this model of performance holds! But does it...?

It turns out it's extremely difficult to actually benchmark disk reads, beacuse you're dealing with layers and layers of caching abstractions. It's easier to do with writes, but even in that case it's hardly trivial.  

The more times you run a read benchmark, the faster it gets as the operating system begins to cache the data even beyond what you'd expect to see in the field. With Java, the virtual machine also speculatively recompiles the code as it figures out which parts are hot. 

This observer effect is very difficult to get around. The closer you examine the problem, the harder it is to tell what you are even benchmarking (other than the benchmark itself).

Overall, it's really hard to find good resources on programming for SSDs, perhaps in part because it's so hard to benchmark. I don't like being told not to worry about this when disk I/O is the primary limiting factor of my search engine.

So I've gathered a pittance of links I could find here. 

* [Recommendations for SSD programming (not all great)](https://codecapsule.com/2014/02/12/coding-for-ssds-part-6-a-summary-what-every-programmer-should-know-about-solid-state-drives/)
* [Commentary on the above recommendations](http://nextaaron.github.io/SSDd/article1.html)

* [This suggests that random reads from SSD is so fast it doesn't matter, but that is ignoring the very real benefits of page alignment in the operating system.](https://web.archive.org/web/20120512160541/http://www.acunu.com/blogs/irit-katriel/theoretical-model-writes-ssds/)

* [Interactive Latency Numbers Every Programmer Should Know (main memory reference vs SSD random read)](https://colin-scott.github.io/personal_website/research/interactive_latency.html)

* [10.2 B Trees and B+ Trees. How they are useful in Databases](https://www.youtube.com/watch?v=aZjYr87r1b8)


Please let me know if you are aware of additional reading on this topic.

## Write-in suggestions

* [Array Layouts for Comparison-Based Searching ACM J. Exper. Algorithmics 22(1), 2017, arXiv:1509.05053](https://arxiv.org/abs/1509.05053)
* [Memory Layouts for Binary Search](https://cglab.ca/~morin/misc/arraylayout)

