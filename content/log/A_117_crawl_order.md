---
title: 'Crawl Order and Disorder'
date: 2025-03-27
tags:
- search-engine
---

A problem the search engine's crawler has struggled with for some time is that it takes a fairly long time to finish up, usually spending several days wrapping up the final few domains. 

This has been actualized recently, since the migration to slop crawl data has dropped memory requirements of the crawler by something like 80%, and as such I've been able to increase the number of crawling tasks, which has led to a bizarre case where 99.9% of the crawling is done in 4 days, and the remaining 0.1% takes a week.

This happens for a few reasons, in part because the the sizes of websites seem to follow a pareto distribution and some sites are just very large, but also because the crawler limits how many concurrent crawl tasks are allowed per common domain name.

This limit is to avoid accidentally exceeding crawl rates by crawling the same site via different aliases.  It's also flat necessary to avoid getting blocked by anti-crawler software on some domains, especially in academia which tends to have an egregious number of subdomains often served by a small number of relatiely underpowered machines.  They also tend to host some of the largest websites, often with tens or even hundreds of thousands of documents. 

The limit varies based on domain name, certain larger blog hosts has a very generous limit, whereas `edu` and `gov` domains tend to have very the most restrictive limits.

The original crawl order was random.  This shuffling of domains was done to ensure that if the crawler ever did end up with some unfortunate crawl order that caused problems for a website (via e.g. domain aliases), or the crawler was caused to run out of memory (no longer an issue), this would not repeat itself every time.

Though in practice, what ended up happening was that through poor luck and the push of domain limits, larger (often academic) domains were often started late.

As these websites take a lot of time to crawl, it's desirable to start them as soon as possible, rather than choosing the order at random.

The next idea was to sort the crawl tasks by the number of subdomains for the domain name, and then use a random ordering as a tiebreaker.

This really did not have the intended effect.

The change ended up creating a shotgun, blasting a blog host with dozens of simultaneous requests at 1 second intervals, as a number of crawl tasks were started at the same time and were given the same crawl delay instructions in robots.txt.

Oops!

To avoid this unfortunate pattern, I added some jitter to the delay between requests.  This makes it so that the request timings will drift apart even if multiple crawl tasks are started at the times.

I also changed the sort order to not order the domains strictly by how many subdomains they had, but whether they had more than 8 subdomains, to get a better mixture.  The aim was never to prefer the crawling of blog hosts after all, but academic websites. 

This revised change appears to have worked, and schedules the slowest crawl tasks first.  Though it won't completely fix the problem, which is in part a consequence of the batch oriented model of crawling the search engine uses, it will at least make better use of the crawler's runtime.

Further optimizations to this could also be to store information about the time the crawl task took the last run, and sort the tasks based on that, though this is information that is not currently available, though it may be possible to use the on-disk size of the historical crawl data to approximate this information. 
