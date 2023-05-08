+++
title = "Growing Pains"
date = 2022-03-23
section = "blog"
aliases = ["/log/52-growing-pains.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


The search engine index has grown quite considerably the last few weeks. It's actually surpassed 50 million documents, which is quite some milestone. In February it was sitting at 27-28 million or so. 

About 80% of this is side-loading all of stackoverflow and stackexchange, and part of it is additional crawling. 

The crawler has to date fetched 91 million URLs, but only about a third of what is fetched actually qualifies for indexing for various reasons, some links may be dead, some may be redirects, some may just have too much javascript and cruft to qualify.

As a result of this growth spurt, some scaling problems have made themselves apparent. This isn't the first time this has happened, and it's nothing that can't be fixed.

## Preconversion

The search crawler writes index data in a journal. It does this in an order that makes sense from its point of view, basically groups of words that occur per document, this is because the crawler downloads one URL at a time. 

Schematically the data looks like this:

  in memex.marginalia.nu/log/48-i-have-no-capslock.gmi these keywords were important: "capslock", "keyboard", "computer", "memex"

  in memex.marginalia.nu/log/50-meditation-on-software-correctness.gmi these keywords were important: "software", "bug", "requirements", "memex"

For a search engine to actually be able to seach, it can't go through records like that one by one. This would start falling apart at just a few thousand documents. Instead, the data needs to be transposed, so that it is arranged in terms of documents per keyword. That is, like this:

   "memex" occurs in: memex.marginalia.nu/log/50-meditation-on-software-correctness.gmi, memex.marginalia.nu/log/48-i-have-no-capslock.gmi
   
   "keyboard" occurs in: memex.marginalia.nu/log/48-i-have-no-capslock.gmi
   
   "bug" occurs in: memex.marginalia.nu/log/50-meditation-on-software-correctness.gmi
   
This transposition is a fairly slow process as every document to be indexed needs to be considered. At the current time, it's about 35 Gb worth of dense binary data (both keywords and URLs are represented as numbers).

To make it possible to search different parts of the internet, to search among blogs or among academia separately, the search engine has multiple smaller indices that contain only some websites. Originally, when building these indices, the entire file was considered. 

The transposition process reads through the file multiple times, first to figure out how many documents are per word, then to tentatively put those documents into a file ordered by word, then to create a mapping of keywords. 

Because it takes this many passes, it is faster to have a pre-conversion step that breaks it down into the data each index is interested in beforehand. 

Preconversion reads through the file once, and produces eight different files containing only a subset of the original data. This has worked well to speed up transposition until recently, but has now gotten untenably slow. 

The problem was that it was reading the big index file, as well as writing to the eight smaller index files on the same mechanical hard drive, causing the disk to have to seek very aggressively, eating into the time it is available for reading and writing, degrading its performance. 

The fix was easy, write the preconversion output to another physical hard drive, and the payout was shaving the 20 minute preconversion down by five minutes. I would like it if it was faster than that, but this is still a big improvement.

## SQL

The search engine uses a SQL database for some of its metadata, MariaDB to be specific. 

The database contains mappings from internal numeric IDs to domains, urls; mappings between domains and URLs, linking information between domains, and so on. The usage is fairly basic but there's just a lot of data in the database. At this point, it takes 30 seconds to do a select count(*) from the URLs table, which contains at the time of writing 218 million known URLs.

I'm low-key looking to migrate away from this as it's not all that well suited for the job, and doesn't make good use of the Optane drive it's on. It's just I don't quite know where I'm going to go. If I can't find anything, I may whip up a bespoke solution, but I'd rather not as there is enough work with the (bespoke) search engine index. 

Until then I'm putting out fires. I've tried tuning the database a bit better, and it may have gotten faster but not enough to make a real difference.

Most of the slow queries are joins, especially touching the URLs table.

Fixing them is not as easy as just adding an index. These tables are well indexed, but they're getting so large that even *with* appropriate indices, queries can easily can take several seconds (without indices it would be more like 30 minutes). Ten second page loads are not a great experience, and it's also a bit of a vulnerability on my end, as one could feasibly overload the SQL server by refreshing a page that causes such a query a couple of times per second. 

I'm getting around it by precalculating data that doesn't necessarily need to be live, such as the views for number of known, visited and indexed documents in the site overviews. The downside is that information may be stale, and in most cases this isn't a huge problem, but from a maintenance perspective, it's more that can go wrong.

There was also a pretty significant performance degradation in the exploration feature for similar reasons, but that should be fixed now as well. Some of the images currently load fairly slowly, but that should pass in a couple of days. That particular drive is being used for a very large calculation and sees a lot of access contention.

### MariaDB Memory leak

It also turns out that MariaDB has a bit of a memory leak. It's probably not from a bug like forgetting to de-allocate resources, but rather from looking at what other people are saying, it seems a problem with heap fragmentation. The effect is the same, causing it to very slowly accumulate memory usage. 

For more conventional use, this might be fine, but as it stands, I'm really pushing the limits of the hardware so it's important that services stay relatively fixed in memory requirements otherwise stuff starts getting killed off by the dreaded OOMKiller.

I'm not a huge fan of having cron jobs that restart services at random intervals so I would like to avoid that if at all possible. Word is that you can mitigate this memory creep by changing the memory allocator from malloc to something like tcmalloc or jemalloc. This does seem to at least slow it down a tad. 

# What's Next?

It works until it doesn't, and then I go looking for something else that works. This has been how building this search engine has been, pretty much from day one. Getting to a million documents required optimizations, so did getting to ten million. I think I can make it to a hundred, and no doubt that will require yet more tweaks and fine-tuning. 

It's difficult to predict what will break beforehand. I know the index transposition will get slower and slower, I know the SQL database is struggling, but it may be something else entirely that blows out next.

There are paradigms that are almost guaranteed to scale well up to a very large scale without these problems, but the crux is that they have a fairly high constant cost. 

That is, building the system that way would not allow me to do as much with the hardware the system is running on. The admittance fee to large scale computing is large scale computers. 

I'd like to see if I can't do the same with a small computer instead, if nothing else than for the sake of shifting the power balance. What if you don't actually need a data center and a budget the size of the GDP of a small country to run a search engine. What if it's within the reach of humans? Wouldn't that be a kicker...

## See Also

* [Command Line Tools Can Be 235x Faster Than Your Hadoop Cluster](https://adamdrake.com/command-line-tools-can-be-235x-faster-than-your-hadoop-cluster.html)

* [/log/06-optimization.gmi](/log/06-optimization.gmi)

