+++
title = "The Evolution of Marginalia's crawling"
date = 2022-08-23
section = "blog"
aliases = ["/log/63-marginalia-crawler.gmi"]
draft = false
categories = []
tags = ["search-engine", "bots"]
+++


In the primordial days of Marginalia Search, it used a dynamic approach to crawling the Internet. 

It ran a number of crawler threads, 32 or 64 or some such, that fetched jobs from a director service, that grabbed them straight out of the URL database, these jobs were batches of 100 or so documents that needed to be crawled. 

Crawling was not planned ahead of time, but rather decided through a combination of how much of a website had been visited, and the quality score of that website determined where to go next. It also promoted crawling websites adjacent to high quality websites.

Tweaking this process to get a good mix of depth and breadth was pretty tricky, but for a moment, this approach worked very well.

Initially the crawling was seeded with a few dozen URLs. This dynamic crawling approach allowed the process to bootstrap itself.

The crawler did on-the-fly processing, that is extraction of keywords and so on, and loading, that is insertion into the URL database and search engine index. Downloaded websites were saved in a big shared tarball in the order they were retrieved across all threads. 

While great for bootstrapping, this approach doesn't scale. Eventually the crawler spent more time waiting for the database to offer up new crawl instructions than it did waiting for websites to load. It also demanded the database to have a lot more indices than otherwise necessary, making writes slower and the disk footprint bigger than necessary. 

The benefits were bigger when the search engine was small and starting up. At this point it already knows a fairly decent chunk of the Internet, at least the sort of websites that are interesting to crawl. 

Orchestration was also very incredibly finicky, to be expected. A director process kept track of all the crawling, it knew which domains were being crawled to avoid multiple crawler threads attacking the same domain at the same time. State was distributed over the SQL database, the director, and the crawler. 

This was a multi-process multi-threaded application with a rapidly mutating shared state, with a patchwork of caches to make it perform well. There's good reason we usually avoid those types of designs when possible. 

I knew this as I designed the thing, but at the time, the search engine was just a hobby project with no users and in such a context it's fun and educational to try cursed design patterns.

At best it worked decently well. Better than you'd expect for a design that is inevitably going to have more mystery race conditions than that time the Scooby Doo-gang went to visit the Nürburgring. 

I would never quite figure out why it seemed to sometimes re-crawl some jobs. 

A just as big problem is that the crawler did everything all at once, which made debugging very difficult. The idea of archiving the downloaded HTML was good, but the execution was lacking, since it was all in huge tarballs and out of order.

Tarballs do not allow random access, so retrieving the HTML code for a specific address to investigate how it interacted with the code could take several minutes as the system had to comb through hundreds of gigabytes of data to find it. (I store these archives on a cheap 5k RPM NAS drive).

This design was scrapped for something more robust and scalable. 

## Batch Crawling

First, a crawl plan is created, this is essentially a compressed file where each line is a JSON entry containing an ID, a domain name, and a list of URLs to crawl. This is specified ahead of time rather than on-the-fly like before.

The IDs are randomized, and used to determine order of crawling. This shuffles the order of domains, and reduces the likelihood of the crawler visiting the same backing server under different domain names even for servers with many subdomains (like sourceforge or neocities). 

The process is broken into three sequential steps, all mediated by compressed JSON. Crawling, Processing, Loading.

Schematically:

```
    //====================\\
    || Compressed JSON:   ||  Specifications
    || ID, Domain, Urls[] ||  File
    || ID, Domain, Urls[] ||
    || ID, Domain, Urls[] ||
    ||      ...           ||
    \\====================//
          |
    +-----------+  
    |  CRAWLING |  Fetch each URL and 
    |    STEP   |  output to file
    +-----------+
          |
    //========================\\
    ||  Compressed JSON:      || Crawl
    ||  Status, HTML[], ...   || Files
    ||  Status, HTML[], ...   ||
    ||  Status, HTML[], ...   ||
    ||     ...                ||
    \\========================//
          |
    +------------+
    | PROCESSING |  Analyze HTML and 
    |    STEP    |  extract keywords 
    +------------+  features, links, URLs
          |
    //==================\\
    || Compressed JSON: ||  Processed
    ||  URLs[]          ||  Files
    ||  Domains[]       ||
    ||  Links[]         ||  
    ||  Keywords[]      ||
    ||    ...           ||
    ||  URLs[]          ||
    ||  Domains[]       ||
    ||  Links[]         ||    
    ||  Keywords[]      ||
    ||    ...           ||
    \\==================//
          |
    +------------+
    |  LOADING   | Insert URLs in DB
    |    STEP    | Insert keywords in Index
    +------------+    
    
```

The emphasis of this design is that each computational step is isolated and repeatable, and the intermediate data steps are portable and inspectable. It works as you would expect a networked application to work, except the "network traffic" is written as a record in a file in the filesystem and acted upon in a later and separate step.

Each step in crawling and processing is resumable and idempotent. A journal file tracking what's confirmed to be finished is used to continue if the process is aborted.

The first design lacked these aspects, which made developing new features quite miserable since it needed to be done either on small ad-hoc datasets, or live in production.

It should be conceded that the new design would probably not have worked well for bootstrapping itself. The first design was a necessary intermediate step to obtain the data to move on to this one. 

The original crawler was also smarter in many ways, and since it did everything all at once was able to short-circuit crawling if it detected that it didn't find anything interesting at all. The new crawler is dumber and has much worse signal-to-noise ratio when it comes to what is actually downloaded. 

Compressed JSON isn't the fastest format for reading or writing, but it doesn't need to be either since the bottleneck is the network connection. As such the intermediate protocol can be optimized for what's most convenient for development. 

The crawler consists of a number of threads that each take a domain name and set of URLs and downloads them in sequence, while adding newly discovered URLs to the queue up until a crawl depth limit. These threads are mostly waiting, either for I/O or for the delay between crawls. 

This could be designed to reduce the number of threads, by rotating tasks among a smaller set of threads using some form of priority queue, but as it stands the network is the bottleneck so that's probably just complicating things for no reason at this point. 

A gotcha I recently ran into when attempting to scale up crawling was that by default, an astronomical number of sockets ended up stuck in TIME_WAIT, which is a sort of clean-up state the Linux kernel puts sockets in to avoid data loss. For 1024 parallel connections, I tens of thousands of sockets in this state. This filled up the conntrack-table of the router, packets were dropped, connections were refused. That's not great. Setting SO_LINGER with a low number reduced this to a more manageable 2-3x the number of connections.

Part of the problem is some of the network hardware is pretty low powered, far removed from anything enterprise grade and it just doesn't deal with huge numbers of connections well. (If anyone knows good ways of tweaking Linux servers and OpenWRT routers to deal with this, please email them to me ;-)

Another approach to widening the crawl is to speed it up. There's not much to do when there's a robots.txt specifying crawl-delay or if you get HTTP Status 429 requesting a slow-down, but for the rest, when there is no indication of how fast to crawl, instead of sleeping for a fixed 1-second crawl interval as has been the default, the crawler has been modified to mirror the behavior of the server. If it takes 400ms to serve the request and process the data received (including write it to disk), the crawler will wait 400ms to request again (but no less than 250 ms, and no more than 2500 ms). This way slow servers get a more lenient treatment, while faster servers that can handle more don't get unnecessary courtesy.

There is also a point to not crawling too aggressively across sites, to reduce the amount of DNS queries, and avoid tripping bot detection algorithms.

The big benefit of this crawling overhaul is the portable data, it is much easier to work with and develop against. It's much easier to inspect the behavior of the code and to find bugs. It's accelerated the development cycle of things like advertisement-detection. I built a filter for detecting which documents contain recipes, from idea to working feature in less than two hours. It would have simply not been possible without the portable crawl data that's now available. The design also allows testing the system with subsets of real production data. 

It is an improvement in almost every way and what's most exciting is the doors it opens for developing the rest of the search engine.

