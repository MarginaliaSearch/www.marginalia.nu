+++
title = "New Solutions Creating Old Problems"
date = 2021-09-14
section = "blog"
aliases = ["/log/21-new-solutions-old-problems.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I've spent some time the last week optimizing how the search engine identifies appropriate search results, putting far more consideration into where and how the search terms appear in the page when determining the order they are presented. 

Search-result relevance is a pretty difficult problem, but I do think the changes has brought the search engine in a very good direction.

A bit simplified, I'm building tiered indices, ranging from

* Words in the title and first H1-tag
* Words in the title, all H*-tags, and <B>-tags,  keyword meta-tags.
* Capitalized Words in text
* Words in text

The indices are queried in the order listed above, so that (hopefully) most relevant results are extracted before mere off-hand mentions.

Another change is that queries are broken down into several possible N-grams, which are searched in decreasing order of length. I did this to a very basic degree before, but this is much more exhaustive.

Determining that a term doesn't exist in the index is an incredibly fast O(1) process, so performing many queries for N-grams that don't exist isn't a problem, even if this results in a large number of queries for a single search.

Example: If you type "Starcraft 2 Legacy of the Void" into the search bar, the search server will perform these queries:

```
starcraft_2_legacy_of|the_void 
starcraft_2|legacy_of_the_void 
starcraft_2_legacy|of_the_void 
starcraft_2_legacy|of_the|void 
starcraft_2|legacy_of_the|void 
starcraft_2|legacy|of_the_void 
starcraft_2|legacy_of|the_void 
starcraft_2|legacy|of_the|void 
```

The search code only constructs (up to) 4-grams, and caps them to at most 16 to prevent denial-of-service searches that generate astronomical numbers of queries in the backend. 

There is no "starcraft|2|legacy|of|the|void" because "2", "of", and "the" are stop words; that is words that are not indexed in isolation and can be trivially discarded from consideration. 

I think I've made good progress, since a lot of the problems I'm starting to encounter aren't teething problems, but the sort of problems "real" search engines struggle with. That's actually pretty exciting!

## Keyword Stuffing and Search Engine Manipulation

Keyword stuffing is really an old problem, and why many search engines for example disregard keyword-tags. It really is what it sounds like. I ended up looking at the tag only when it is sufficiently short. This seems a workable compromise for now. 

I also had some problems with extremely SEO-savvy sites showing up in the top results. Like, your mobile apps and stuff, but that turned out to be the result of a bug in the order the indices were prioritized, so now they are back in the bottom of the page.

## Very Esoteric Queries

If you search for "Scamander", you'll get an idea of what I mean. 

It's a river in Turkey, known today as Karamenderes. In the Iliad, Achilles who is known for his mood swings, gets so goddamn angry he picks a fight with the river Scamander, known as Xanthos by the gods (yeah, I don't get it either). More recently, Newt Scamander is also some J.K. Rowling character.  

There just aren't any good results for Scamander. If you scroll down quite a bit you may find a passage in Cratylus by Plato where Socrates is appealing to the wisdom of the Iliad to make a point about names and their relationship to what they represent, but that's the absolute highlight of the search results. 

You get better results if you qualify the search as "scamander iliad", or "newt scamander", but this is a tricky one. It hopefully will improve as I index further. 

To be fair, there really aren't any good results on google either. Just storefronts shilling Harry Potter merchandise, but that's to be expected.

## Political Extremism, and Other Distasteful Content

There has always been some amount of results where the author is frothing at the mouth over cultural marxists or the jews or Trump or various culture wars nonsense, but that's just the nature of the Internet in the 2020s. For a while it felt like I was getting too many of these results, even in queries it really shouldn't show up, but it seems to have settled down a bit. 

In general, I do not believe it is my job to police other peoples' ideas, no matter how much I disagree with them. Thought-policing is far greater evil than disagreeable ideas.

At the same time I don't want my search engine to become the go-to search engine for extremists. That's not a good look. But I'll cross that bridge when I come to it.

So far I'm doing nothing as long as they aren't doing bait-and-switch tactics that cause them to show up in innocent queries. If I find something especially distasteful I might just blacklist the site.

I've employed a similar tactic toward porn, escort sites, and the like. If I find them while searching for something innocent, I'm blacklisting them; but I'm not going out of my way to make sure they don't exist anywhere in the index, as even if I wanted to, that's just not feasible. There is a lot of smut on the Internet.

## Search Engine

* [https://search.marginalia.nu/](https://search.marginalia.nu/)

## See Also

* [https://encyclopedia.marginalia.nu/wiki/N-gram](https://encyclopedia.marginalia.nu/wiki/N-gram)
* [https://encyclopedia.marginalia.nu/wiki/Stop_word](https://encyclopedia.marginalia.nu/wiki/Stop_word)

