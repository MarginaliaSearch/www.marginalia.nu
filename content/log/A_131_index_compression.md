---
title: 'Index Compression, Query Execution Improvements'
date: 2026-02-13
tags:
- search-engine
- nlnet
---

The Marginalia Search index has recently seen some design tweaks
to make it perform better, primarily the introduction of postings list compression.

Last year, the index was partially [re-implemented with SSDs in mind](/log/a_123_index_io/).
This was largely a success, but left some lingering issues with tail latencies that sometimes weren't what they needed to be.

To ensure predictable execution times, 
the query execution is provided a timeout value,
after which it will wrap up and return the best results it's found.
Query execution was so flaky that the *actual* timeout used when terminating the execution used to be something like 50ms lower than the provided value. 
This is obviously not a fantastic state of affairs. 

Part of the problem is that when the index was re-designed, 
some design decisions were made based on single-consumer benchmarking,
that did not translate to good performance when multiple consumers were competing for the bandwidth.

The index was doing too many large reads at the same time,
and as reads would pile up on the I/O queue,
tail latencies would mount,
exaserbated by the fact that many of these reads had strong interdependencies.
The work could not finish until all reads from a batch were finished, 
so even just the one delayed read could significantly delay query execution.

So the plan was to find ways to be smarter about how reads are planned to reduce contention,
and find other ways of eliminating unnecessary I/O.

## Approximate Positions 2.0

Since then the index structure saw some minor tweaks in order to allow the storage of a bitmask
representation of term positions.  This was how the search engine originally implemented position matching,
a design that has been superceded by [term positions lists to allow phrase matching](/log/a_111_phrase_matching/).  

The original design was resurrected alongside the position lists as it allows the elimination some provably 
irrelevant documents earlier in the processing pipeline, without paying the cost of reading term positions.

Eliminating irrelevant documents early means more time can be spent ranking documents that are more likely to be relevant.

To figure out which positions are likely to be adjacent, 
we want a bit mask so that 

`mask(a, n) & mask(b, n) =/= 0` if `abs(a-b) < n`.

In pseudo-python, the mask is constructed like this:

```python

min_dist = 24
bit_width = 56

def create_mask(pos)
  mask = actually a long but let's pretend it's not

  set_bit(mask, pos)
  set_bit(mask, pos + min_dist)

  return mask

def set_bit(mask, n):
  mask[(n // (2*min_dist)) % bit_width] = 1

```

If we didn't smear out the mask by sometimes setting two bits, 
we'd run into the problem that e.g. `create_mask(48) & create_mask(49)` returns 0,
despite the positions being closely adjacent.
Smearing out the mask by setting the adjacent bit when in the upper half of `pos % min_dist` turns it into a mask that actually captures positions with a given minimum adjacency of `min_dist` for all positions.

This is a slightly simplified explanation. In practice the mask also encodes some flag bits, 
that allow us to bypass terms that e.g. have high TF-IDF,
as we may not want to require such terms to be adjacent to other query terms in order for a document to be counted as relevant in this filtering step.

The I/O savings come from the fact that we can typically read multiple values in the same disk read operation, 
and this is a read operation we need to do regardless to figure out where the position data is.

As part of this change, 
values were moved out of the index blocks, 
into a separate structure.

Without this block design modification, 
growing the bit width of the values associated with each key would lead to index blocks consisting of mostly value data, 
and such read amplification is generally undesirable as it consumes more I/O bandwidth than we need to read a bunch of data we probably won't need.

We can come back and read the values later once we've decided which documents we are interested in.

Schematically, the change looks like this

```
  Before                  After
 +---------------+      +---------------+
 | # items       |      | # items       |     (separate file)
 | # ptrs        |      | value offset  | -> +--------+
 | forward ptrs  |  =>  | # ptrs        |    | values | 
 |   ...         |      | forward ptrs  |    |  ...   |
 | keys          |      |    ...        |    +--------+
 |   ...         |      | keys          |
 | values        |      |    ...        |
 |   ...         |      +---------------+
 +---------------+

```

## Compression 

From this point, 
compressing the keys is conceptually pretty easy.

Block compression is widely used, 
almost universally recommended in the literature,
and has very few downsides.
It saves both space, 
and disk I/O, 
and generally improves performance.

The change is conceptually simple.

1. Compute the differences between subsequent (sorted, deduplicated) document IDs.
2. Variable byte encode the differences.

Due to the nature of how document IDs tend to be arranged,
with long runs of closely adjacent values, 
this leads to a 80% compression rate with real world data.

One reason behind choosing such a simple compression scheme is that
when compressing data in a block-based data structure, 
you need a performant way of answering how many items can be compressed to fit in a block,
given some byte size constraint. 

Many compression algorithms (and even most vbyte implementations) 
can at best tell you how big the compressed representation of the data will be.
With vbytes, this is more of a nuisance as it's so easy to calculate,
but answering this for something like `gzip` or `zstd` is more involved,
and given we already have excellent compression rates and good performance,
there's not really much point reaching for such algorithms.

Elsewhere variable bit encodings are used to compress e.g. term positions,
this gives a better compression rate, but is at the same time significantly slower
to decompress.

Vbytes decompress very fast <sup><a href="#foot1">[1]</a></sup>,
which makes them the pragmatic choice here.

In benchmarks, 
this change doubles index query lookup performance, 
and cuts the postings data file to a third its original size.

The speed-up is mainly down to a reduction in I/O roundtrips.  
Given each read has a 50-100us latency, 
getting more data with each reads means a faster index lookup. 
You can accomplish a similar effect just using larger reads, 
which is how the index originally solved the problem,
and that works in a vacuum, 
but as a side effect it uses much more of the I/O bandwidth, 
creating contention with other I/O tasks such as position reads, 
which is part of the tail latency problem was coming from.

## Execution Improvements

To further address the I/O contention issue, 
the index execution pipeline was overhauled.  

Execution was already concurrent, 
but not in a particularly resource effective way, 
often scheduling too many parallel I/O reads.

It arrived at this state through a sort of death by a thousand optimizations, 
where many small improvements that made sense at the time and in a vacuum,
collectively led to code that wasn't very effective.

Analysis of the thread behaviors showed that it often took considerable time for data to flow through the previous steps to reach the ranking step,
as so much of the I/O work was done in bulk.
This meant the ranking step didn't have a lot of time to do any actual ranking.

The principal change was to move from having a small number of threads each offloading multiple read tasks onto an io\_uring queue, 
to having a larger number of threads doing synchronous reads.  

The system technically allows using io\_uring here, 
but it's not really a use case where it helps, 
as there are too many dependencies between the reads,
especially given there may be multiple queries executing simultaneously,
competing for places in the io\_uring queue and inflating each others' latencies even more than the I/O queue itself does.

While io\_uring excels at independent parallel reads, 
the workload has too many read dependencies and too much query-level contention, 
making synchronous reads with more threads more predictable.

To help improve resource utilization, 
the execution pipeline was moved to use finer grained concurrency,
using lock free ring buffers to pass individual documents, 
instead of batches of them.
This is a pretty well proven design that sees ~10ns latencies.

The old query execution pipeline looked like this:

```

 +--------+
 | Lookup | x query variants
 +--------+
     |
     | docIds[1-512]
     v
 +----------------+ x 2
 | Read positions |  Performs concurrent reads using `io_uring`
 | Fetch metadata |  up to like 32 in flight at a time. 
 +----------------+
     |
     | annotated document data[1-512]
     v
 +---------------------+ x 8
 | Rank results        | 
 | Give result to heap |
 | (heap deduplicates) |
 +---------------------+


```

The new query execution pipeline looks like this:

```

 +--------+
 | Lookup | x query variants
 +--------+
     |
     | docIds[1-512]
     v
 +------------------+
 | Deduplicate ids  | x 1
 +------------------+
     |
     | docIds[1-512]
     v
 +---------------------------------+ x 4
 | Read index values               | 
 | Fetch metadata                  |
 | Filter based on position masks  |
 +---------------------------------+
     |
     | (docId, position offset), individual
     v
 +----------------------+ x 8
 | Read positions       | Sequential reads.
 | Rank result          |
 | Give to result heap  |
 +----------------------+

```

The new design uses more threads than the previous one,
but the risk of oversubscription is pretty low as most of these threads spend most of their time waiting for I/O.

## Results

The work aimed to deal with tail latencies and inefficient resource usage,
and it's been successful in that regard.

Average disk read has dropped from sitting at 80 MB/s to about 20-30 MB/s,
with peaks and valleys as query intensity changes over time.

Tail latencies are also much more predictable.  For queries executed with a 250 ms timeout,
there used to be regular spikes of up to 700ms execution times.  These have all but vanished.

With the fixes, P90 latency is 249ms, P95 is 273ms, P99 is 324ms.

## Footnotes

<a name="foot1">[1]</a> Even *extremely fast*, as these can be SIMD-decoded. See e.g. Lemire et. al.'s [stream vbyte](https://arxiv.org/abs/1709.08990).  Using downcalls to the stream vbyte decoder would be a compelling experiment, even though at this time the code doesn't seem at all bottlenecked by the decompression speed.  Though that will have to wait as considerable time has already been spent fiddling with index optimizations, and there are other parts of the search engine in more urgent need of attention.
