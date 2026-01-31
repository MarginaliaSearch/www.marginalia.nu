---
title: 'Trust in Ranking'
date: 2026-01-31
tags:
- search-engine
---

The Marginalia Search default ranking algorithm recently saw a fairly radical improvement, due to a new domain trust system that drastically reduces the number of content farm results, as long as there are human results it usually finds them across all the usual test queries.

Recently fixing a few bugs that made the search engine work more correctly had the unexpected and undesired side-effect of also making it surface more search engine spam and content farm-type results.  

To work around this undesired outcome, a trust based model was evaluated and found to perform almost unreasonably well, despite being simple bordering on naive.

## How does it work?

A large set of trusted domains known to be high quality was selected.  These websites are almost all written by humans and low in spam. I will not share exactly which websites these are, as it paints a target on them [for black-hat SEO](https://www.marginalia.nu/log/20-dot-com-link-farms/).  

I've also evaluated this technique on the links from the HN '[share your website](https://news.ycombinator.com/item?id=36575081)' thread and had similar results, so anyone looking for viable ersatz data that's a good dataset to play with that is at least approaching a reasonable sample size, though with a bit of a skew toward tech.

From this dataset, the link graph was consulted<sup><a href="#lg">[1]</a></sup>, and the set of domains directly linking to and from the trusted domains were categorized by how well they are connected.  

The categories are

* In the trusted set
* Bidirectionally linked >= 5 times
* Outgoing link >= 5 times
* Incoming link >= 5 times
* Bidirectionally linked < 5 times
* Outgoing link < 5 times
* Incoming link < 5 times
* Not directly rachable

Depending on the size of the untrusted domain, i.e. how many documents are identified and indexed, a penalty is applied based on which category it falls into.  Larger websites are hit harder than smaller websites, poorly connected websites are hit harder than strongly connected ones.

Not that numbers alone really say anything without context, the penalties currently look like this:

```java
switch (connectivity) {
  case DIRECT, UNKNOWN -> 0.;
  case BIDI_HOT -> size < 250 ? 0. : -0.5;
  case REACHABLE_HOT -> size < 250 ? 0. : -1.;
  case LINKING_HOT -> size < 250 ? -3. : -4.;
  case BIDI -> size < 250 ? -5. : -7;
  case REACHABLE -> size < 250 ? -5. : -8.;
  case LINKING -> size < 250 ? -5. : -10.;
  case UNREACHABLE -> size < 250 ? -15. : -25.;
};
```

This doesn't so much promote any particular website, avoiding the self-reinforcing winner-takes-all mechanics of purely popularity based ranking, but instead removes websites that are very unlikely to be relevant, unless they are among the only websites with results for the query.  This combines with other ranking factors, such as [how many ad networks a website connects to](https://marginalia-search.com/site/dimden.dev?view=traffic), to promote mostly clean results.

One of the major drawbacks of PageRank is that a malicious actor can create a whole network of websites to affect the rankings at large, so that even just a single tenous connection to the larger link graph can lead to massive distortion.  

Without malicious manipulation, looking only at direct links is much worse, but in the context of link graph manipulation it makes these types of attacks far less impactful, as an attacker would need to spend significant effort creating bidirectional links to websites in this unspecified set to have significant scale success with manipulating the rankings.

The heuristic is still not without drawbacks. As with any reputation based system, it becomes harder for new websites to establish a foothold.  This will eventually resolve itself by just participating in the web, linking to other websites, etc. 

The other problem is that it works poorly across language barriers, so for now this is only enabled for English queries.

... but overall it works suprisingly well, so well in fact that the queries that have typically been used for evaluating the search engine rankings are almost unusable now, they return results that are too good.  They return essentially the types of results they should return, with very little in terms of spam present.  

The one notable exception is ironically '[search engine](https://marginalia-search.com/search?query=search+engine)', which returns too many results about 'search engine optimization', though the problem with that may be elsewhere.   [This reddit thread](https://old.reddit.com/r/Eldenring/comments/hraue7/elden_ring/) also shows up as one of the best results for 'elden ring', also hinting that there's some work to be done.

<hr>

<a name="lg">[1]</a> Link graph export containing only indexed domains can be downloaded here: [https://downloads.marginalia.nu/exports/linkgraph-26-01-src-dst-named.csv.zst](https://downloads.marginalia.nu/exports/linkgraph-26-01-src-dst-named.csv.zst) (warning: 671MB download, 3.1GB uncompressed).  
