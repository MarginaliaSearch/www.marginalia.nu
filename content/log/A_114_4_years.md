---
title: 'Marginalia Search: 4 Years'
date: 2025-03-03
tags: 
- search-engine
---

This update is a few days late, the canonical birth date of the project is Feb 26.  

It has been another year of Marginalia Search.  The project is still ongoing, still my full time job, although the project is entering a somewhat more mature phase of development, most of the big pieces are in place and do a decent job at what they do.  

The [roadmap for the project](https://github.com/MarginaliaSearch/MarginaliaSearch/blob/master/ROADMAP.md) is available on GitHub.

## Web Design Overhaul 

As the search engine itself has started to feel relatively competent now, it seemed like a good time to overhaul the web design, a new look to reflect it's enhanced behavior.  

In part this was technically motivated, as the old web design was a bit of a pain to work with.  There were features I wanted to add in where I was reluctant to do so because of how much of a hassle working with the CSS had become.  The system also used the Spark web framework, which isn't actively maintained, as well as a template language that was a bit annoying and limited.

In their place, Tailwind, Joooby and JTE.  I'm very happy with these tech choices, work on the front end became a lot less of a headache.  

As these types of web design changes aren't welcome by everyone, the old UI will [remain available](https://old-search.marginalia.nu/) but feature-frozen as long as I'm able to securely keep it around.

The search engine has also been migrated off the `search.marginalia.nu` domain off to `marginalia-search.com`, as it's really grown too big to just be a weird appendix growing from my personal website, and is able to stand on its own now.

## Slop for Crawl Data

[Slop](/log/a_112_slop_ideas/) is a small spin-off project, a self-describing columnar data format that's optimized for sequential consumption; intended to replace poorly performing Parquet storage solutions used by the search engine.  

It's still in an alpha state, but it's now replaced parquet for crawl data as well as intermediate storage.  Replacing all data storage with an alpha state storage format probably seems risky, but it's offset by how simple the storage format is.  The sorts of nooks where bugs tend to hide in data storage simply don't exist in the code.

This has drastically reduced the memory utilization of the crawler, as well as cut the processing time in half for finished crawl data.  The crawler's memory utilization was getting so out of hand I was faced with having to bump the crawler's Java heap up to 256 GB, but after migrating to Slop memory usage dropped by a ton and the crawler can now run on something like 32 GB. 

This is very helpful, as not only is the crawler less likely to crash, reducing the iteration time and processing requirements for the crawl data makes development go a lot faster.  One of the biggest pains working with web search is that the feedback loops can sometimes be measured in weeks.  

I haven't gotten to the bottom of it, but my hunch is that the Java parquet library is leaking memory, or at least not using it in a way that the garbage collector is happy about.  This probably won't matter in most applications, except the crawler keeps running for over a week chewing through tens of thousands of parquet files (hundreds in parallel), which I imagine might really magnify problems like these.
