+++
title = "Lexicon Architectural Rubberducking"
date = 2022-04-11
section = "blog"
aliases = ["/log/55-lexicon-rubberduck.gmi"]
draft = false
categories = []
tags = ["programming", "search-engine"]
+++


I'm going to think out loud for a moment about a problem I'm considering. 

RAM is a precious resource on any server. Look at VPS servers, and you'll be hard pressed to find one with much more than 32 Gb. Look at leasing a dedicated server, and it's the RAM that really drives up the price. My server has 128 Gb, and it it's so full it needs to unbutton its pants to sit down comfortably. Anything I can offload to disk is great.

A significant amount of the memory usage is in the lexicon. The lexicon is a mapping between search terms, words (sometimes N-grams) to a unique numeric ID, as these IDs are a lot more space-efficient than indexing words as strings. 

The contract for the lexicon is that every time you enter a specific string, you get the same number back. This number is unique to the string.

At the moment of writing, the lexicon has about 620,000,000 entries. 

These strings are of average length 6-7 bytes, so the smallest it's ever going to get is about 4-5 Gb. The strings are already compressed.

What I'm using is:

```
  8 Gb off-heap for a hash table 
+ 6 Gb on-heap for metadata
+ 5 Gb off-heap for the string data itself
-------
= about 20 Gb
```

Assigning unique IDs to arbitrary length strings isn't entirely a trivial problem when the number of IDs creeps toward the billions, but this memory consumption is still unreasonable.

Maybe a DBMS can fix this? URLs mapping on MariaDB, 200k URLs, is just ridiculously large ~40Gb. MariaDB probably can't solve this with the hardware I have available. Maybe some other database?

## What if we just use hashes as identifiers?

Can we find a hash of such a size that we can accept hash collisions as so unlikely it won't matter?

The Birthday Paradox becomes a significant problem when the number of items N is such that the number of distinct hash values M < N^2.

```
M   = 18446744073709551616 = 2^64 
N^2 = 384400000000000000   = (620,000,000)^2
```

It *could* work with a 64 bit hash, but a 128 bit hash would feel a lot less sketchy. It would also use a lot more space. Caveat: I would need a very good hash function for this math to work out. Murmur3?

## Hold my beer...

What if we create a hash table on disk, the key is the hash from above, we size it to 2^32 entries, this should allow for a lexicon of ~2^31 entries with good retrieval performance. 

Disk size would be 16 or 32 Gb depending on 64 or 128 bit hashes. We can use the cell number the final hash is put into as an ID.

This is just crazy enough to work, but it would depend on having extremely solid random write IOPS on the disk, or enough RAM to do the construction entirely in memory. Maybe journal the writes and then reconstruct the hash table only after a crash. This *may* be acceptable, but makes a ton of RAM and/or enterprise SSDs mandatory for running this software.

An additional drawback is that this mapping can't ever grow beyond 2 billion entries. This may be acceptable, might be able to scooch it up by multiples of 2 by by partitioning on some bit that isn't part of the table hash. The drawback is that this configuration can't be changed without reconstructing the entire index.

The real upside is that this may make it possible to remove the requirement for 7 bit ASCII keywords. 

Need to sleep on this.



## See Also

* [/log/06-optimization.gmi](/log/06-optimization.gmi)