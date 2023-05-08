+++
title = "Search Result Quality For Multiple Terms"
date = 2023-03-23
section = "blog"
aliases = ["/log/76-search-result-quality-for-multiple-terms.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


This is a bit of a follow up to the previous post.

* [The Grand Code Restructuring [ 2023-03-17 ]](/log/75-grand-restructuring.gmi)

Marginalia's search result quality has, for a long while, been pretty good as long as your search query is a single term, but for multiple search terms it's been a bit hit-and-miss. Marginalia was never great at this, but the quality of results in this usage pattern has taken a bit of a dive recently due to a re-write of the index last fall.

During The Grand Restructuring, the opportunity arose to isolate the code responsible for result ranking and expose it to some well-needed scrutiny. It turns out it was pretty broken. 

With most things programming, the big obstacle is how to understand the problem, the solution usually follows trivially once you do. So the emhasis on this post will be just that, understanding the problem.

At a high level, result ranking is a two-phase operation. Two services are involved. The index service, and the search service.

1. The index service finds up to a few thousand good search result candidates. It ranks them based on relatively scant data that is encoded in a forward index. This is primarily bit flags that mark words that have high TF-IDF, appear as subjects in sentences, appear in titles, and so on. It's a heuristical grab bag. 

2. It takes the 100 best results, and returns them to the search service that re-ranks them by joining them with a SQL table that contains additional metadata. The search service calculates a more sophisticated ranking that's based on BM-25, but also considers things such as whether terms appear in the URL or title of the document.

A problem with this set-up is that when you have two successive selection/ranking functions, it's not clear which one is broken. It's relatively easy to assess the search service's arrangement of the results, but harder to assess the index service's selection process.

It turns out the two can be separated by using "site:"-searches as this will in most cases select all viable results for a domain. If you, for example, search for "plato symposium site:historyofphilosophy.net" and the top two results are the expected episodes

  Wings of Desire: Plato's Erotic Dialogues
  Frisbee Sheffield on Platonic Love

These are the podcast's two episode on Plato's Symposium, and what we would expect. If you just search for "plato symposium" and instead find an episode on The Republic

  Soul and the City: Plato's Political Philosophy 

... as the result for historyofphilosophy.net, then something is wrong when the index selects its results, and this causes an interaction where the site may rank poorly although it has a pretty good results for the query. 

This method has been very useful in diagnosing how these selection and ranking processes work in isolation.

As a result of being easier to interact with, the search service's ranking algorithm was at least in an "ok" working order, much better than the selection process, which misbehaved quite a lot as a result of being relatively inaccessible. 

The biggest problem was that when a query includes multiple terms, it calculated an average on how well the terms matched each document. Sometimes this is good, but this let a result being a very good result for 'plato' offset the fact that it wasn't a very good result for 'symposium', and this result would rank better than a result that would be a decent match for both terms.  Instead of calculating an average, the search engine now selects based on how well the least good term ranks. 

Overall, the calculations are much simpler now, as they tend to become with increased scrutiny. 

This work also led to the realization that the BM-25 calculations in the search service can be improved.  Earlier Marginalia used a static term frequency dictionary for this, it tended to be a bit stale and takes several seconds to load. ... but that's unnecessary, as the index service can look up term frequencies for the query as it executes it! The search service gets fresh statistics straight out of the oven every morning.

This will go live hopefully beginning of next week. The new crawl is done, currently processing the data.

## Code


* [The Index Service](https://github.com/MarginaliaSearch/MarginaliaSearch/tree/master/code/services-core/index-service)

* [The Search Service's Ranking Logic](https://github.com/MarginaliaSearch/MarginaliaSearch/blob/master/code/features-search/result-ranking)

