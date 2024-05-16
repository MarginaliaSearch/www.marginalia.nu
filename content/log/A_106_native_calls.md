---
title: 'Experiment in Java native calls'
date: '2024-05-16'
tags:
- 'search engine'
---

I've experimentally replaced some of the Java implementations of quicksort and binary search with calls to C++ code, and saw huge benefits for the sorting code but the same or worse performance for binary search.

The Marginalia Search engine is mainly written in Java, which is language that is good at many things, but not particularly pleasant to work with when it comes to low level systems programming. 

Unfortunately, a part of building an internet search engine involves database-adjacent low level programming. 

I've had in the back of my head the idea of replacing some of that code with calls to native C++ functions instead now that Java's new [FFM API](https://docs.oracle.com/en/java/javase/22/core/foreign-function-and-memory-api.html)s are stable, in part just to get access to a language that is better suited to this type of programming, but also because there might be performance benefit.  

(Aside: I'd been toying with the for quite some while, but never looked deeper into it as I ran into some logistical issues with distribution and loading of the library.  For reference,  the key is to bundle the .so with the jar, and then when it's time to load it, write it to a temporary file and then load from that file.  This isn't very well documented and it took complaining on the Internet to find the answers.)

For the experiment, I targeted a few relatively hot methods including sorting and binary search.  The former is used in index construction, and the latter in query execution.

An annoying part of working outside of the Java heap is that you do not have access to Java's builtin sorting algorithms, and sorting numbers is important to constructing database indices.  This means the search engine uses a custom implementation of quicksort, which is pretty basic.  The system also needs to be able to sort pairs of 64 bit integers based on the first key, which is definitely not something Java has builtins to deal with even on heap, so there's reason suspected that C++'s std::sort might be better and definitely a lot more ergonomic.

The binary searches were fairly straightforward translations of the equivalent Java code.  There's probably performance to be gained from rewriting them in a branchless style, but for the sake of reducing the distance between the two implementations, it'll do for now.

After running some benchmarks, it appears that the C++ code is faster at sorting, but how much faster depends on which Java implementation is used.  

The codebase offers two implementations for off-heap memory, one using MemorySegment and its get, one using the aptly named Unsafe.  The difference is that the former will bounds-check your accesses if it can't prove they are safe, and the latter will blow a SIGSEGV-shaped hole in your foot if you get it wrong.  (There's technically a third way to access off-heap memory in Java, which is the old ByteBuffer-based API, but they're cruel and unusual)

For binary searches, it's a bit of a wash slightly favoring Java.

# Results

## 64 bit sort 

25 trials, graalvm 21.0.3, N=2<sup>10</sup>

| Implementation | ops/s | Error p=99% | rel% native|
|----------------|------------------|-------------|------------|
| native         | 118.452          | 3.673       | 100.00%    |
| unsafe         | 104.164          | 1.681       | 87.94%     |
| memorysegment  | 76.940           | 0.363       | 64.95%     |

Compared to memorysegment, the C++ code is so much faster there's really no debate, but vs unsafe the performance is surprisingly close, especially given the likely suboptimal implementation of the Java sorting algorithm.  

## 128 bit sort 

25 trials, graalvm 21.0.3, N=2<sup>9</sup>

| Implementation | ops/s | Error p=99% |rel% native|
|----------------|------------------|-------------|-----------|
| native         | 226.487          | 6.614       | 100%      |
| unsafe         | 139.904          | 5.511       | 61.77%    |
| memorysegment  | 98.226           | 5.153       | 43.37%    |


The disparity between the 64 and 128 bit algorithms is possibly due to the 128 bit swap implementation.  I haven't looked deeply into what might be going on there.  Other conceivable explanations may be that there's some hidden implementation difference, or that GCC is better at optimizing 128 bit sorts than JVMCI.  

The native performance seems as expected though, as it's sorting the same number of bytes with roughly half the number of comparisons (as the record size is twice as large).  In this light, the behavior in the Java case is peculiar to say the least.

## 128 bit binary search 

25 trials, graalvm 21.0.3, N=2<sup>9</sup>

| Implementation | ops/s | Error p=99% |rel% native|
|----------------|------------------|-------------|-----------|
| native         | 5,505,182        | 78,912      | 100%      |
| java           | 5,627,717        | 247.913     | 102.2%    |

There was no difference in runtime between the unsafe and memorysegement implementations, likely because the JIT understood it could omit the bounds checks.  Even though the benchmark finds no significant difference between the native code and the Java code, it's likely the JIT compilation discovered a new optimization somewhere during the benchmark, as the performance shot up from 5.5M to nearly 6.3M, explaining the larger error.  

All else being equal, the C++ version is hobbled in that it can't be inlined by the java compiler.  Since these functions have sub-microsecond runtimes, small things like that begin to matter.  There may also be different explanations, such as how the code was compiled.  Maybe the Java compiler found a branchless version or something.  This is just a first experimental look at running these functions natively, so I haven't gone to the length of scrutinizing either compiler output.

As an example of how small things matter, initially when these tests were run, the results were bimodal for the native implementation, where sometimes an iteration would finish at 4,700,000 ops/s and sometimes at 5,500,000.  This headscratcher turned out to be caused by memory alignment.  After increasing the alignment to 16 bytes from 8, the execution times stabilized immediately.  This bimodality was not visible in the 128 bit sorting benchmarks.

The binary search results do raise the question of whether the Java sorting algorithm will beat the native C++ call for small datasets, where we expect very fast function call times.  Running some quick informal benchmarks in this domain, for N=32 items to be sorted, this does not appear to be the case; C++ pulls ahead even further, with nearly 6.8M ops/s vs 1.2M ops/s.  This is likely due to C++' std::sort using an introspective sorting algorithm that is better suited than the basic quicksort implementation from the Marginalia codebase.

Overall the experiment is a success.  Exactly how and when to best incorporate these native calls, and how to manage having the same code implemented in multiple languages, all that is still an open question, but it is still a success.

It's also fascinating how fast the Java sorting code was in comparison, where somewhat a poorly optimized "we've got quicksort at home"-tier implementation ended up with a 13% performance hit against std::sort for the 64 bit implementation. 
