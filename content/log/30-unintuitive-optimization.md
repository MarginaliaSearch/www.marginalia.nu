+++
title = "Unintuitive Optimization"
date = 2021-10-13
section = "blog"
aliases = ["/log/30-unintuitive-optimization.gmi"]
draft = false
categories = []
tags = ["programming"]
+++


Optimization is arguably a lot about intuition. You have a hunch, and see if it sticks. Sure you can use profilers and instrumentation, but they are more like hunch generators than anything else. 

This one wasn't as intuitive, at least not to me, but it makes sense when you think about it.

I have an 8 Gb file of dense binary data. This data consists of 4 Kb chunks and is an unsorted list containing first an URL identifier with metadata and then a list of word identifiers. This is a sort of journal that the indexer produces during crawling. Its main benefit is that this can be done quickly with very high fault tolerance. Since it's only ever added to, if anything does go wrong you can just truncate the bad part at the end and keep going.

I construct a reverse index out of this journal. The code reads this file sequentially multiple times to create pairs of files, partitioned first by search algorithm and then by which part of the document the word was found.

Roughly

```
For each partition [0...6]
  For each each sub-index [0..6]:
    Figure out how many URLs there are
    Create a list of URLs
    Write an index for the URL file
```

This takes hours. This does several slow things, including unordered writing and sorting of multiple gigabytes binary of data, but the main bottle neck seems to be just reading this huge file 105 times (it's reading from a mechanical NAS drive) so you can't just throw more threads at this and hope it goes away.

I had the hunch I should try to pre-partition the file, see if maybe I could get it to fit in the filesystem cache.

This part feels a bit unintuitive to me. The problem, usually, is that you are doing disk stuff in the first place, so the solution, usually, is to reduce the amount of disk stuff. Here I'm adding to it instead.

New algorithm:

```
For each partition [1...6]
  Write chunks pertaining to partition to a new file

For each partition [1...6]
  For each each sub-index [1..6]:
    Figure out how many URLs there are
    Create a list of URLs
    Write an index for the URL file
```

As the partitions do overlap, it means writing approximately 13 Gb to a slow mechanical drive, but it also means the conversion doesn't need to re-read the same irrelevant data dozens of times. The prepartitioned files are much smaller and will indeed fit snugly in the filesystem cache. 

This does reduce the amount of stuff to read by quite a lot, if you crunch the numbers it goes from 1.2Tb to 267 Gb (assuming 21 passes per partition). 

```
884M    0/preconverted.dat
1.6G    1/preconverted.dat
91M     2/preconverted.dat
928M    3/preconverted.dat
192M    4/preconverted.dat
1.2G    5/preconverted.dat
7.8G    6/preconverted.dat
```

The last of the files is bigger because the last partition accepts the 90% of the domains no algorithm thinks is particularly worthwhile. Sturgeon's Law is extremely applicable to the field.

Running through the last partition takes a long as running through partitions 0-5. Conversion time was slashed from hours to just over 40 minutes. 

A success!

