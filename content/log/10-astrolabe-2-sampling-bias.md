+++
title = "The Astrolabe Part II: The Magic Power of Sampling Bias"
date = 2021-08-03
section = "blog"
aliases = ["/log/10-astrolabe-2-sampling-bias.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


As I have mentioned earlier, perhaps the biggest enemy of PageRank is the hegemony of PageRank-style algorithms. Once an algorithm like that becomes not only dominant, but known, it also creates a market for leveraging its design particulars.

Homogenous ecosystems are almost universally bad. It doesn't really matter if it's every computer running Windows XP, or every farmer planting genetically identical barley, what you get is extreme susceptibility to exploitation.

It's why we have link farms, it's why there's an SEO industry, and it's in part why the internet has gotten so bad since those that cater to the algorithm are shaped by it, and those who don't are invisible.

## Quality Assessment

To get search results that are interesting again, a some different method needs to be devised.

If the problem is that everyone is trying to cheat the popularity contest, maybe we can cut the gordian knot by looking at something other than popularity.

Maybe we can infer that websites that specifically don't try to win the popularity contest have some intrinsic value. Maybe we can cook up a measurement that looks for indicators of SEO, and punishes that.

This in mind, I created a score based on mark-up. Simplified it calculates a score that roughly gauges how "plain" a webpage is.

```
       length_text     -script_tags
  Q =  -----------  x e
       length_markup
```

There are other factors too, specific words also reduce the score, mostly pertaining to porn, bitcoin and warez, as those are problem areas that yield very few legitimate results and a lot of spam.

For the rest of the post when I use the word quality, I will refer to this score. "Low quality" is not a judgement, but a number.

Note that for each script tag, quality is reduced by 63%.

* 1 script tag and quality can be no more than 37%
* 2 script tags and quality can be no more than 13%
* 3 script tags and quality can be no more than 5%

... and so forth. Script tags are the biggest factor in a web page's quality assessment.

There are drawbacks to this, not every use of javascript is exploitative. Sometimes it brings usefulness, but those web sites will be de-prioritized.

## Indexing

This score drives the crawling priority of each website the crawler discovers. It flavors the quality of the outgoing links too, so that to best effort, websites are crawled in a decreasing order of quality.

Naturally the assumption doesn't hold that a website looks like the websites that link to it, but I think the reverse assumption is better. Low quality websites rarely link to high quality websites.

The search engine will only index one or two pages low quality pages it encounters and then probably never look back.

Indexed websites are then sorted in eleven different buckets based on their quality (actually its negated logarithm, from 0 through -10). These buckets allow the index to be queried in order of decreasing quality, as the index has no other awareness of the pages' quality.

Given that there are very real constraints on how big the index can get, maybe 20-30 million URLs, the main priority in crawling is finding the most salient pages and aggressively rejecting everything else. One million high quality URLs is better than a billion low quality URLs.

While in general I am a friend of Voltaire and advocate tolerance well beyond what most people would consider reasonable, in this case I promote extreme prejudice. Ruthless concessions need to be made to ensure quality. If it raises the quality of the index, nothing is off limits.

I talked about that a bit in the post on link farms I made earlier.

## Relevant Search Results

When it's time to query the index, during searching, the index buckets are queried in decreasing order of quality. The results are then sorted in order of how many incoming links the domain has weighted by the page's quality.

Superficially this is an outdated and broken way of building a search engine since link farms and other trash results will almost by definition produce high numbers of incoming links, but what makes it work is the shewed sample created by the crawling process. It is possible to find results from the full gamut of quality, but low quality results are just rarer.

It's not that the search results are picked in order of how many links they have, it's the results that have already been picked that are prioritized in that order in order to present the best ones first.

I implemented this last point relatively recently, and the result has been pretty remarkable. As long as you are within an area where there actually is pages to find, the search engine not only finds them, but often shows relevant results at the top. I'm really happy with how well it's working now.

Then there's the problem areas, where you can't find anything relevant. I mentioned porn and bitcoin earlier, but also travel, security systems, locksmithing, SEO; these topics do not produce good results. They seem absolutely inundated with spam. I've blacklisted the spam domains, but it's been like peeling layers off an onion. The more I removed the less there remained, until eventually there was nothing at the core.

It remains a niche search engine. I do use it as my default search engine on my phone mostly because I believe in eating your own dogfood, but it's still challenging. I keep bouncing between it and the big search engines. If I can't find it on mine, I try theirs. If I can't find it there, I try mine some more. It's a coin toss sometimes.

* [On Link Farms](/log/04-link-farms.gmi)
* [The Astrolabe Part I](/log/01-astrolabe.gmi)

* [https://search.marginalia.nu/](https://search.marginalia.nu/)

