---
title: "Marginalia Search receives FUTO Grant"
published: 2023-09-15
tags: 
- "search engine"
---

I'm happy to announce that the generous people at [FUTO](https://futo.org/) have granted the project $15,000 with no strings attached to help the search engine out with some more server power.  

FUTO is a young Austin, TX-based organization "*dedicated to developing, both through in-house engineering and investment, technologies that frustrate centralization and industry consolidation*".  It's one to keep an eye on, I believe their heart is in the right place and they have every possibility of making a real difference. 

As for Marginalia Search, is very a timely windfall. 

I've been pushing ever closer the limit of what's possible to do on PC hardware for quite a while, and despite recent improvements and optimizations, I think I'm relatively close to some sort of upper limit.  Maybe I can double the size of the index one more time, but I think that's about as far as it's going to go.  Working with a system that's always close to the limit in terms of RAM and disk space is tedious and slow in a way it doesn't need to be, and the dinky size of the index is almost certainly one of the bigger limitations for the search engine.

The gist of the plan moving forward is something like this.

The search engine itself will move out of my apartment and onto proper enterprise-grade hardware in a server rack somewhere.  My income from this work is unpredictable to say the least, so investing a known sum into hardware upfront and having a minimal burn rate from colocation is the only way forward where I'll be able to sleep soundly at night (you can always find other uses for a server if things really go disastrously wrong).

I don't believe the software itself will need extensive modifications to make use of the hardware, but it may be advisable to shard some of the processing to make better use of multiple disks and cores.  This is trivial as most of the problem space is embarrassingly parallel all the way from crawler to search results page, you can just shard by domain and save for domain rankings the data flows as straight as a box of uncooked spaghetti.

The current production machine will be downgraded to a building and staging environment.  Not having such an environment is the biggest pain point I have right now, many changes can't be completely tested before deploying them in production.  It's not a very professional way of running a server and a leading cause of downtime and jank, but it's also had to be that way because I've lacked the hardware.

The search engine software is ultimately still going to be designed for lower powered hardware.  Not only do I think it's important that there isn't a prohibitive $15,000 entrance fee to running a search engine, it's central to my programming philosophy to always target small hardware.  This reveals performance problems early on while they are still easy to deal with.  Anything that runs well on a small computer runs even better on a larger one.  The converse is not true.

Exciting times ahead!  Thanks FUTO and everyone else contributing to making this possible.
