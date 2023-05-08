+++
title = "Web Browsing"
date = 2021-10-09
section = "blog"
aliases = ["/log/28-web-browsing.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


An idea I've had for a long time with regards to navigating the web is to find a way to browse it. 

"Browse" a difficult word to use, because it has a newer connotation of just using a web browser, I mean it in the old pre-Internet sense, browse like when you flip through a magazine, or peruse an antiques shop, not really looking for anything in particular just sort of seeing if anything catches your eye. 

Stumbleupon used to do this pretty well, although completely randomly. I wanted something with more direction. 

In a previous attempt, I had an idea that you could use outgoing links to accomplish effect, but the result just wasn't particularly impressive. With the discovery (and subsequent bastardization of) the PPR algorithm, I gave it another shot. 

I calculated a modified personalized pagerank for every domain in my search engine and stored it away in a database. This is about a million domains, but I excluded the periphery of the graph so in practice it was more like 150k domains that needed getting a ranking. It's easy to run this in parallel so it only took about two hours, that's manageable.

The presentation is super sketchy and not nearly finished, but the effect is so cool I wanted to share it. 

A sample of origin points:

* [Beautiful Fansites](https://search.marginalia.nu/search?query=browse%3Awww.wild-seven.org&profile=yolo&js=default)

* [Personal Websites](https://search.marginalia.nu/search?query=browse:bikobatanari.art&profile=yolo&js=false)

* [Tildeverse](https://search.marginalia.nu/search?query=browse%3Atilde.team&profile=yolo&js=default)

* [Plan 9](https://search.marginalia.nu/search?query=browse:9p.io&profile=yolo&js=default)

