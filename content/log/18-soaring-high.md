+++
title = "Soaring High"
date = 2021-09-02
section = "blog"
aliases = ["/log/18-soaring-high.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I'm currently indexing with my search engine. This isn't an always-on sort of an affair, but rather something I turn on and off as it tends to require at least some degree of babysitting.

I've also been knocked out by the side-effects of the vaccine shot I got the other day, so it's been mostly hands-off "parenting".

What I'm trying to figure out just how far I can take it. I really don't know. I took some backups and just let it do its thing relatively unmonitored. 

I've done this several times before. I let it go, and find where it falls apart, fix it, and let it go again to see which new soaring heights it will reach. 

So far this run there has been a few points of data congestion that needed clearing out. A semaphore here, some optimization there, but for the most part, it has just been chugging along with an ominous ease. 

I've run it for a few days now, and the index is about thirty-five million URLs in size. The size when I started was about fifteen million. Thirty five million is already breaking a record. Will it make fifty million? A hundred? I really don't know. It could easily blow up in a calamitous fireball in the next fifteen minutes.

The true limits are beyond my comprehension. There are too many variables at play to predict where the they are, and whether it is *the* limit. So far there has always been another optimization that has been able to save the day. For how long will those boons continue? Surely there must be some upper bound to a search engine hosted in an apartment living room. 

I know of one boundary: The dictionary hash table. I know it will start to degrade noticeably, like most hash tables, when it's about 75% full. I know it growth seems linear, or at least linear-bounded, slowly ticking up by about six million entries per hour. I know that it's full capacity is 2.1 billion entries, and it's currently at 752 million. That means we are half way to 75% full. That is a vague boundary. A lethargic death-by-brownout, rather than a splat against some unseen brick wall. 

I know a brick wall, too, the partition holding the files for the mariadb instance that keeps track of URL metadata is about 37% full, at 44 Gb. That could be what blows up. MariaDB could also quite simply grind to a halt because it doesn't get enough ram. I've assigned it 40 Gb. It should be enough for a while. But I really don't know for how long.

Maybe it's some envious plot of the operating system resource management that will ground the flight of the search engine. Right now the server OS gets 55 Gb of buffer memory. So far that keeps the disk thrashing at bay. So far.

Incidentally, searching is a tad slow now, but that's not because it's approaching some performance limit, but because the caches aren't properly populated. Searching more fixes the problem. But there's also a script I run which just goes through a dictionary making queries that brings the query time down. Looks like a DOS attack, just spamming dozens of searches per second in a loop, but it's actually the opposite. Ironically, the worst thing for the search engine's performance is not getting enough search queries. 

Meanwhile, the search engine keeps indexing. Perhaps like a bumblebee crossing a road, blissfully unaware of the windshield hurdling its way.

## Links

* [https://search.marginalia.nu/](https://search.marginalia.nu/)
* [gemini://marginalia.nu/search](gemini://marginalia.nu/search)

