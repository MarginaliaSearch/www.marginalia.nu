+++
title = "Fun with Anchor Text Keywords"
date = 2022-06-23
section = "blog"
aliases = ["/log/59-anchor-text.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


Anchor texts are a very useful source of keywords for a search engine, and in an older version of the search engine, it used the text of such hyperlinks as a supplemental source for keywords, but due to a few redesigns, this feature has fallen off. 

Last few days has been spent working on trying to re-implement it in a new and more powerful fashion. This has largely been enabled by a crawler re-design from a few months ago, which offers the crawled data in a lot more useful fashion and allows a lot more flexible post-processing.

It is easy enough to grab hyperlinks within the same domain that is being crawled and process them on the spot and assign the keywords to each document. 

Unfortunately these are often not very useful. 

Not only are the keywords often non-descriptive, 'read more'-type stuff, there's an additional benefit to external links, as they are other people describing websites. That tends to be more align well with the sort of keywords people enter into a search engine. When we use a search engine, we're not infrequently describing the document we're looking for. 

"python manual"
"cheap car parts"
"job interview tips"

This is why the best links are other websites' links, but they are also the hardest links to deal with. 

There are practical problems, as the keywords are not located near the document they refer to, but rather scattered over other documents. Before being loaded, they must be deduplicated and grouped by the document they refer to. 

The grouping is necessary because it saves a lot of work for the index construction to be able to say "here is a document, and these are its keywords: [...]", rather than loading them one by one.

Grouping can be done by pre-sorting into a few dozens or hundreds different output files, making the file sizes manageable for fine-grained in-memory sorting and loading later.

Of this the deduplication is harder problem due to the sheer volume of data. To show why keyword deduplication is tricky, let's break out the napkin math!

* If we have 100,000,000 documents
* Each document has on average 4 unique keywords
* Each keyword is on average 9 bytes
* Each URL is on average 51 bytes
* Then all (document,keyword) requires at least 4x60x100,000,000 bytes
* That's roughly 24 Gb
* That's without considering any sort of language overhead! 

Oof :-(

This has the potential to be a real memory hog, maybe you could get away with it but it seems super sketchy. You could of course keep it on disk, but then it would be impossibly slow and a real nasty IOPS hog. 

There are enough weeks long processing jobs in this search engine, and it really doesn't need more of them.

Thinking about this for a while, the solution that sprang to mind was pretty simple. 

A big old bloom filter. 

Make it 2 Gb or so, which means a bit set with a cardinality of 16 billion. Hash collisions would be expected as the birthday paradox limit where there is a 50% chance of a single hash collision is sqrt(16 billion)=126k. That's arguably within what is acceptable as at the expected 4 keywords per document, the filter is only populated to a degree of 0.00025%, which also becomes its worst case false rejection rate assuming a perfect hash function.

Call it an optimist's hash set. Sometimes good enough is good enough, and the solution is nice and constant in both time and space. 

## Results

Having run some trials extracting keywords for links to documents currently indexed by the search engine, the results are promising. 

The code is extremely fast, almost surprisingly so, it runs through even a large body of documents such as StackOverflow in about an hour.

The raw output from the experiment can be downloaded here:

* [External Links, Crawled Data [2.8Mb]](https://downloads.marginalia.nu/links/links-crawl.tsv)
* [Internal Links, Crawled Data [48 Mb]](https://downloads.marginalia.nu/links/links-internal.tsv)
* [Exteral Links, Stackoverflow [12 Mb]](https://downloads.marginalia.nu/links/links-so.tsv)

Below are keywords sorted by frequency, which will tend to raise the least informative keywords to the top. It illustrates how there is a significant lexicon of junk keywords that needs to be excluded, demonstratives like 'here' and 'this', navigation elements and so forth. 

### External Links, Crawled Data Subset 10k domains

```
    408 website
    399 page
    350 link
    201 race
    200 web
```

Note: The sample is skewed by a racing website that basically has the anchor text 'race' for a lot of links.

### Internal Links, Crawled Data Subset 10k domains

```
  17385 content
  17276 skip
  14664 next
  10986 previous
   7549 read
```

### External Links, StackOverflow

StackOverflow seems to provide high value keywords overall, even its junk words are frequently informative.

```
   4701 documentation
   3061 docs
   2680 link
   2418 page
   2418 here
   1885 article
   1813 tutorial
   1539 example
   1207 guide
   1174 official
   1079 doc
```

Wikipedia seems less useful, because a lot of its links just mirror the title of the website they link to, which means they don't provide any additional information. 

It would be interesting to look at Reddit comments as well. While it is basically the internet capital of astroturfing, given that the links are filtered by all the criteria needed for inclusion in the search database, it may still be a good source.

In general, the limited scope of the search engine and the existing filtering is probably something that has a decent chance of limiting the impact of spam links. 

## Closing thoughts

This is far from finished, but it's a very promising lead. 

There will be a major upgrade of the search engine coming in about a month or so, mostly necessitated by running out of disk space on the database hard drive, and there is no way of moving forward with this without essentially rebuilding the database. I have ample backups so it's not as scary as it sounds, worse comes to worst it'll go back to being a stale copy of itself. It's honestly a welcome opportunity to fix old design mistakes to make the code more workable. This feature is slated to be included in that upgrade.



## See Also

* [Bloom Filter](https://encyclopedia.marginalia.nu/wiki/Bloom_Filter)
* [Birthday Paradox](https://encyclopedia.marginalia.nu/wiki/Birthday_paradox)

* [Stackoverflow Data](https://archive.org/download/stackexchange)