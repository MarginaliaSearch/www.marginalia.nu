---
title: 'Deep Bug'
date: '2024-04-10'
tags:
- programming
- search-engine
---

The project has been haunted by a mysterious bug since sometime February.  It relates to the code that constructs the index, particularly the code that merges partial indices.  

In short the search engine constucts the reverse index through successive merging of smaller indices, which reduces the overall memory requirement.

You can conceptualize the revese index itself as two files, one with offset pointers into another file, which has sorted numbers.  This code runs after each partition finishes crawling and processing its data, and has a run time of about 4 hours. 

Suddenly the code that merges the indexes started to randomly fail. 

What failed was the code that copies sorted numbers from one of the older indices to one of the newer, in the case when a keyword is present in only one of the indexes and no actual merging of sorted lists is needed. 

If code suddenly starts acting up when the amount of data increases, all my intuition screams that this must be a 32 bit integer overflow.  The index construction does all of its work in the bermuda triangle of 32 bit errors that is 1-32 GB file size range, so it really does seem like a very probable suspect. 

I went over the code looking for such a thing, and found nothing.  I added a bunch of guard clauses and assertions to get some hint about what was going on, but these didn't turn up much other than the copy operation attempting to copy outside the file.

To my surprise, while doing this the construction process suddenly went through! The index it constructed was sane.  Had I fixed it by perturbing the code somehow?  I ran it again and it failed.

Some non-determinism is expected since the indexes are merged in parallel, so the order they're merged in is a bit random even if the merging itself is completely deterministic.  I felt this explained the random success: I got lucky with the ordering. 

Since I had a work-around I left this be for a while.   I had other work that was more pressing.  The seven remaining partitions were coaxed through by just hitting the restart button until it worked, taking one or more days of hammering restarts.  Annoying and time consuming, but it worked.  

This week the final partition came through, and I had a moment to look deeper into this enigma.

Maybe it wasn't an integer overflow?  I checked the git log for any suspect changes between December when it worked and February when it didn't work, and I found nothing.  Again I combed over the code looking for integer overflows, and still found nothing.

I did find a function that shrinks the merged index, which is initially allocated to be the total size of the inputs.   Since the merge function removes duplicates, the merged index is often smaller than the sum of its parts, but it's impossible to know how small before actually merging.

This seemed like a plausible explanation, since if the files were truncated too hard, it would explain the files seemingly being "too small".  I disabled the truncation, and still got errors.  

In investigating this, I stumbled on a very curious aberration.  I'll sketch out the gist of it:

```java

val = read-only mmapped file 
      not subject to change
counts = zeroed mmap:ed file 

long offset = 0;
for (int i = 0; i < length; i++) {
  counts[i] = val[i];
  offset += val[i];
}

long size = 0;
for (int i = 0; i < length; i++) {
   size += counts[i];
}

// ...

assert (size == offset);

// ...

truncate(size);
```

All this runs in sequence on the same thread, and nothing writes to `counts` other than this code.

The assertion would fail. 

Alright, so it is an integer overflow! ... you might think.  Nope.  These are all 64 bit longs, and the values being added are small and few enough not to overflow a 32 bit integer.  At this point I could reliably isolate the particular inputs that triggered the behavior with the assert, so I did just that.  

There are four lights, damnit!

At this point I patched production so that if this assertion were to fail, the input files were copied over to a separate directory.  This gave me a 2 GB or set of test-data that had been known to trigger the error that I could exfiltrate and examine locally.  

The bug of course did not re-appear when I ran this code in isolation, but that actually says something important.  I'd reduced the problem down to deterministic code being non-deterministic and outputting logical contradictions.  This feels like a good reason to question other things than the program logic.  

It's probably safe to assume the problem is either the JVM, the linux kernel, or the hardware, in decreasing order of likelihood.  

The JVM is at the top of the suspect list since one of the things that *had* in fact changed since the bug appeared was that the project migrated over to graalvm from openjdk. 

Hardware errors typically don't target only a specific function over and over, except I guess if you have some Homer-style divine grudge going on.  Having not skipped over any libations, enraged gods could probably be ruled out, and to further sow doubts about this I was able to reproduce the error on another machine, not with the exfiltrated data but through reindexing Wikipedia's data repeatedly.  This also probably rules out some sort of linux kernel bug, since the kernels were a few versions apart; one machine was SMP and the other was not, one with ECC one not, etc. 

So at this point the only remaining suspect on my list was the graalvm JDK. I migrated the project to the latest graalvm version, from jdk-21 to jdk-22 through oracle's official docker images.  This did absolutely nothing to address the problem.  I switched the docker build process to use a temurin (openjdk) image instead of graalvm, and... the problem went away!  Since then, it's worked over and over. 

At this point I'd love to file a bug report, although I'm having trouble isolating the problem enough to do so.  "Doesn't work" is famously not an error description.  The relevant process is something like 5 KLOC, and the smallest dataset that triggers the bug somewhat reliably is about 54 GB. 

I've isolated the code that manifests the bug and run it 50,000 times on the data exfiltrated from production on a machine that's previously been able to trigger the problem, and it's run without a hitch, so there appears to be some sort of spooky action at a distance going on. I've tried perturbing it in various ways, introducing page faults and so on, since that's happening a lot in production, again to no avail.

In general I'd argue you haven't fixed a bug unless you understand why it happened and why your fix worked, which makes this frustrating, since every indication is that the bug exists within proprietary code that is out of my reach.  This feels like an impasse, not a solution, even though the error has nominally been corrected.  

I can at least say make statements about what hasn't caused the error.