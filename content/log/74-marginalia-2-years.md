+++
title = "Marginalia Search: 2 years, big news"
date = 2023-02-26
section = "blog"
aliases = ["/log/74-marginalia-2-years.gmi"]
draft = false
categories = []
tags = ["search-engine", "nlnet"]
distinguished = 1
+++


No time like the project's two year anniversary to drop this particular bomb...

Marginalia's gotten an NLNet grant. This means I'll be able to work full time on this project at least a year. 

* [https://nlnet.nl/project/Marginalia/](https://nlnet.nl/project/Marginalia/)

This grant is essentially the best-case scenario for funding this project. It'll be able to remain independent, open-source, and non-profit. 

I won't start in earnest for a few months as I've got loose ends to tie up before I can devote that sort of time.  More details to come, but I'll say as much as the first step is a tidying up of the sources and a move off my self-hosted git instance to an external git host yet to be decided. 

## Recap 

It's been a heck of a year for Marginalia. Some highlights.

The UX has been streamlined quite a bit. Forms for flagging problematic websites and submitting websites to be crawled.

Overall the search result presentation is cleaner. The old search result page used a lot of weird emoji icons to convey information, I was never quite happy with that. 

* [The Old Design](https://www.marginalia.nu/junk/pips.webp)
* [The New Design](https://www.marginalia.nu/junk/new.webp)

The crawler was significantly redesigned.

* [/log/63-marginalia-crawler.gmi](/log/63-marginalia-crawler.gmi)

The index has been almost completely rewritten to be both faster and more space-efficient. I feel a bit bad I still haven't written about this. The re-design allowed the search engine to hit that sweet 100M document milestone a few months ago.

I've had big success experimenting with website similarity metrics, and very recently I combined this method with PageRank. The result is good beyond expectations. The new algorithms are live on the search engine and working so well. 

* [Explore Website Similarities](https://explore2.marginalia.nu/)
* [Very rough outline of "marginaliarank"](/log/73-new-approach-to-ranking.gmi)

There's been improvements in ad-detection, text-summarization, topic filtering, DOM-pruning, sharp sticks...

With the grant there will definitely be a "Marginalia Search: 3 years"-post. I got most of the above done while juggling a lot of other life-stuff alongside Marginalia Search, as a solo dev. It'll be very interesting to see what sort of ground I'll be able to cover while working on this full time!

