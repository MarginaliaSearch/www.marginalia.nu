+++
title = "Is There A Better Hard Drive Metaphor?"
date = 2022-04-03
section = "blog"
aliases = ["/log/53-better-hard-drive-metaphor.gmi"]
draft = false
categories = []
tags = ["programming"]
+++


This is mostly a post to complain about something that chafes. I wish there was a programming language (ideally several) that acknowledged that computers have hard drives, not just a processor, RAM and other_devices[].

Something that has struck me when I've been working with the search engine is how unfinished the metaphor for accessing physical disks is in most programming languages. It feels like an after-thought, half left to the operating system to figure out, a byzantine relic of the days when computers had tape drives and not SSDs. 

Reading and writing files is clunky and awkward no matter how you do it. Objects and classes are representations of bytes in memory, effortlessly integrated in the language. Why can't they be representations of bytes on a disk? Between mmap and custom allocators, this seems extremely doable.

It's a jarring contrast to the rest of almost any programming language other than perhaps C. In fact, what you've got is effectively C, with all of its problems and more.

In the rest of the languages, there may be some token effort toward reading files structured as streams of objects, but in general, you are stuck filling buffers with bytes. There is a marked lack of expressiveness in this type of programming.

This has fed into this divide where there are robed greybeard mystics who have peered beyond the veil and know how to access a hard drive effectively, performing eldritch rites with B-trees, ring buffers, and other forbidden data structures you vaguely may remember from your deepest slumber during that one class as a second year undergraduate; and the rest of the programmers who will never awaken to this unspeakable knowledge.

Often we use a DBMS as a stopgap solution to get around the sorry state of disk access, but that in itself is a kludge in many cases. Object-relational mapping is a shoe that never quite fits, and if possible SQL integrates even worse  into other programming languages than disk access does.

Besides, relational databases are hard, it's still too arcane. Let's just turn it into a kv-store with JSON blobs for each value. 

The file system itself is actually a database too. They're based on pretty much the exact same principles and data structures as your average DBMS.

So what you've got is a nightmarish turducken, the file system as the OG NoSQL database from generations past, containing a relational SQL database, containing an ad-hoc NoSQL database. It's like that old Xzibit meme, putting a database in a database so you can database while you database.

Feels like a state of surrender. Sorry guys, hard drives were too difficult to figure out, let's bury them in abstractions and forget they exist. 

We're off on a bad track here, probably starting with the fact that the operating system is attempting to hide the fact that hard drives are block devices from the userspace, while this is something you urgently need to lean into if you want your program to be fast. 

With all the development on new programming languages going on, one more guaranteed to be memory safe than the other, is anyone working on a language that properly integrates hard drives as a first class citizen? Would be a neat thing to explore.

