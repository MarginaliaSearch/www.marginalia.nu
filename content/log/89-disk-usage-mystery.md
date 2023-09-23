---
title: 'A Disk Usage Mystery'
date: '2023-09-23'
tags:
- programming
---

I ran into a bit of a puzzling situation yesterday, testing some of the new index construction changes before they're going live in a few days. 

The process crashed with a pretty non-descript stack trace complaining about illegal instructions, so first glance it looked more like it was within the realm of freak JVM bug, cosmic ray, hardware error maybe.  

I was doing this on my developer workstation, which also spawned a popup complaining that the hard drive it was working on had nearly run out of space, and inferred that the error probably was due to memory mapping more space onto a disk than what was possible.  

Memory mapping is a technique for accesing a file as though it was memory, without needing to call methods like read() or write() to inspect or alter it. 

I ran it again and observed.  Two cups of coffee later, it blew up in the same way.  

Opened the shell to see if I could figure out which file was the culprit.  The new code does allocate a fair bit of temporary files, but they're supposed to be deleted, maybe something wasn't getting cleaned up properly.

What did I find?  Well... not stray files.  

I found that `du` and `df` didn't tally up; the size of the files in the filesystem didn't add up to the size reported by the filesystem.

Usually there will be some discrepancy of maybe a few percent, but this was a more like a 400 Gb discrepancy on a 1 Tb disk.  

Maybe hidden dotfiles?  No, nothing like that.  

Before finding some 'paranormal investigations' production to sell the haunted harddrive to, I restarted the crashed process to try one more time, and the... filesystem shrank back to the size it should be. 

Now it clicked. 

There's *this thing* with memory mapped files and filesystems. 

We need to go into the weeds to understand it; but very simplified, a unix filesystem has a table of files (with path and name), and a table of inodes with various metadata, including a reference count.  The data on disk isn't associated with the filename, but with the inode. 

In practice you can have the same inode referred to by multiple file names, and when you "delete a file", you actually remove the filename associated with the inode. 

The disk space isn't considered free until there are zero references to the inode. 

In most cases, removing all filenames associated with an inode will reduce the reference counter to zero, but it turns out you can also have a file referred to by zero *file names*, but with a non-zero reference counter, which is what was happening here.  

The file had a non-zero reference count because it was memory mapped, even though no filename pointed to it.   The reference counter doesn't decrement until you un-map the memory.

This is where it almost got a bit awkward.  Java has many strengths, but systems programming has historically not been one of them.

Until extremely recently, Java hasn't offered any form of explicit lifecycle control over mmap:ed areas, they've been cleaned up at the discretion of the garbage collector.  

At best you could pray and invoke `System.gc()` -- although it makes no guarantees of actually doing or freeing anything.

Thankfully, with the newly released JDK21 (with preview features enabled) there are means of explicit lifecycle control through <a href="https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/foreign/Arena.html">Arenas</a>.  So the situation is salvageable.

Another old-timey Java limitation that's plagued the project so far is an upper limit on how large areas can be memory mapped, 2 Gb.  That is not a lot, and you can do clever stuff to mostly avoid having to deal with the `pages[idx/pageSize].get(idx%pageSize)`-shaped consequences of this problem and almost get native speeds in most situations, but to be completely honest, it's quite far from what you'd get without the 2 Gb limit.

In for a penny, in for a pound with JDK 21<sup><tt>[preview]</tt></sup>, this too becomes solvable.  Looking at the existing benchmarks for the appropriate code, it's actually quite a bit faster using the MemorySegment API even apart from memory mapped areas. I'm seeing 20-40% speed improvements from moving from LongBuffer to MemorySegment alone.   I'm not sure I can say why that is, but I'm not one to look a gift horse in the mouth.
