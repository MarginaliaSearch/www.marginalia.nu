+++
title = "Faster Index Joins"
date = 2023-01-03
section = "blog"
aliases = ["/log/70-faster-index-joins.gmi"]
draft = false
categories = []
tags = ["programming", "search-engine"]
+++


The most common (and most costly) operation of the marginalia search engine's index is something like given a set of documents containing one keyword, find each documents containing another keyword. 

The naive approach is to just iterate over each document identifier in the first set and do a membership test in the b-tree containing the second. This is an O(m log n)-operation, which on paper is pretty fast. 

It turns out it can be made faster.

A property of the original problem is that you can actually recycle a lot of the calculations when the first set of identifiers is stored in a sorted list. Luckily the data in this case is already sorted by the b-tree structure from which it is retrieved. 

When you look up a document in the b-tree, you're provided with the offset in the data block as well as knowledge of an upper bound for the data in that block. 

This makes it possible to determine whether the next document in the list is also within the range that it belongs in the same block, and if so a linear search can be performed. This can be repeated until it's known that no additional documents exist in the data block. 

The linear search replaces comparatively costly repeated b-tree traversals, and the search is guaranteed to terminate immediately whenever the next item does not belong in the current data block.

The best case performance of this operation is linear, O(m), although this requires very particular and unrealistic arrangement of the data[1]. The average and worse case is O (m log n), with a constant factor is strictly less than or equal to the naive algorithm.

It's extremely hard to provide a good benchmark for how much faster this code is. This type of operation is highly resistant to benchmarking in a meaningful way due to the many layers of caches. Properties of the data may also affect the result. However attempting to isolate or remove such effects is effectively is also questionable as the effects are present in any real-world application. 

With caveats underway, using real world data the new algorithm was found to be between 2x-12x faster than the naive algorithm.

The magnitude of this performance improvement came as a bit of a surprise. It would be expected that it might be faster, as linear searching is in many ways rubbing the modern CPU the right way and while binary searching is in many ways not. Still an order-of-magnitude performance improvement is so remarkable I had to go back and double-check the code is actually doing what the code is supposed to do. It does.

Part of why it's so fast is because each tree traversal incurs at 3-5 binary searches each across 4096 bytes of data. Trading that for a single linear search that often stays within the same cache line is a beneficial trade-off indeed. Adding to this, it also saves a lot of index offset calculations which while just arithmetic do add up when performing them tens of thousands of times as is expected during a query. The fastest calculations are those never performed, and this does remove quite a lot of calculations.

A contributing factor in the speed-up is as alluded to previously that the real world search engine data is not random but rather heavily prone to runs where adjacent document identifiers often belong to the same domain which in turn tend to contain similar keywords. That said, a speed-up was observed on even on poorly correlated synthetic data, albeit much smaller.

[1] For a query where a maximal number of items item in the query buffer can be retained or rejected for each data block, the computational work is completely dominated by the linear search. It technically still is O(m + m/B log n), but the block size B will eclipse log n for any and all realistic workloads.

## Code listing

This code attempts to walk down the b-tree as long as there is data in the buffer. 

```
public void retainEntries(LongQueryBuffer buffer) {
    for (BTreePointer pointer = new BTreePointer(header); 
         buffer.hasMore(); 
         pointer.resetToRoot()) 
     {
        long val = buffer.currentValue();
        if (!pointer.walkToData(val)) {
            buffer.rejectAndAdvance();
        }
        else {
            pointer.retainData(buffer);
        }
    }
}
```

Excerpt from BTreePointer, which encapsulates parameters related to offset calculations (which are omitted for the benefit of the readers' sanity):

```

long boundary = an upper bound for the data in the current data block;
    
public void retainData(LongQueryBuffer buffer) {

    long dataOffset = findData(buffer.currentValue());
    
    if (dataOffset >= 0) {
        buffer.retainAndAdvance();
	
        long searchEnd = ... // omitting distracting offset calculations
	
        if (buffer.currentValue() <= boundary) {
            data.range(dataOffset, searchEnd).retain(buffer, boundary);
        }
   }
   else {
        buffer.rejectAndAdvance();

        long searchStart = ...
        long searchEnd = ... 
	
        if (buffer.currentValue() <= boundary) {
            data.range(searchStart, searchEnd).retain(buffer, boundary);
        }
   }

}

long findData(long value) {
        update boundary and return the data layer offset for "value", 
	       or a negative value if none is found
}


```

Listing of LongArray$retain as referenced in retainData() above:

```
    long get(long offset) {
      return data from the block at "offset"
    }
    
    void retain(LongQueryBuffer buffer, long boundary, long searchStart, long searchEnd) {

        if (searchStart >= searchEnd) return;

        long bv = buffer.currentValue();
        long av = get(searchStart);
        long pos = searchStart;

        while (bv <= boundary && buffer.hasMore()) {
            if (bv < av) {
                if (!buffer.rejectAndAdvance()) break;
                bv = buffer.currentValue();
                continue;
            }
            else if (bv == av) {
                if (!buffer.retainAndAdvance()) break;
                bv = buffer.currentValue();
                continue;
            }
            // when (bv > av) we keep scanning through the block

            if (++pos < searchEnd) {
                av = get(pos);
            }
            else {
                break;
            }
        }
    }
    
    // ...
```

Note the invariant above, bv <= boundary ensures that the code only keeps searching as long as it is known that one or more of the buffer's values can still be retained or rejected. 

Although the names are fairly self-explanatory, for the sake of clarity, the query buffer structure operates with two pointers and is outlined below:

```
public class LongQueryBuffer {

    public final long[] data;
    public int end;

    private int read = 0;
    private int write = 0;
    
    public LongQueryBuffer(long[] data, int size) {
        this.data = data;
        this.end = size;
    }
    
    public long currentValue() {
        return data[read];
    }

    public boolean rejectAndAdvance() {
        return ++read < end; // true when more data can be read
    }

    public boolean retainAndAdvance() {
        if (read != write) {
            long tmp = data[write];
            data[write] = data[read];
            data[read] = tmp;
        }

        write++;

        return ++read < end; // true when more data can be read
    }
    
    public boolean hasMore() {
        return read < end;
    }
    
    public void finalizeFiltering() {
        end = write;
        read = 0;
        write = 0;
    }

}
```

## See Also

* [/log/54-bargain-bin-btree.gmi](/log/54-bargain-bin-btree.gmi)

