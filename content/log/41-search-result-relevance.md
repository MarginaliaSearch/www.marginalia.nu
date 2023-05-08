+++
title = "Search Result Relevance"
date = 2021-12-10
section = "blog"
aliases = ["/log/41-search-result-relevance.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


This entry is about a few problems the search engine has been struggling with lately, and how I've been attempting to remedy them.

Before the article starts, I wanted to share an amusing new thing in the world of Internet spam. 

For a while, people have been adding things like "reddit" to the end of their Google queries to get less blog spam.  Well, guess what? The blog spammers are adding "reddit" to the end of their titles now. 

* [/pics/reddit-spam.png](/pics/reddit-spam.png)

One of the great joys of this project is watching the spammers' strategies evolve in real time.

## Few Results

A persistent problem I've had is simply not getting a lot of results. A part of this is because the index is small, sure, but it still seems like there should be more. Oftentimes there *are* more, if you alter the query a little bit, but that's really hard to see. 

I've had some code generating alternate queries for a while (like pluralizing/depluralizing words), but it's been almost comically dumb and only added additional terms in a few rare cases. A big constraint is budgetary, I simply can't try every possible permutation.

A new approach is to use part-of-speech information to limit which variants are tested, as well as using a term frequency dictionary to filter out alternatives that probably don't exist anywhere in the index. 

To give you an idea of what it's generating, this is the n-grams it will search for if you enter "The Man of Tomorrow". 

the_man_of_tomorrow
man_of_tomorrow
the_man, tomorrow
the_man, tomorrows
man, tomorrow
man, tomorrows

I'm choosing this not only because it illustrates the re-writing logic, but also because it's a bit of a pathological case that shows some bad rewrites. Some of these are clearly more relevant than others. "man, tomorrows" is pretty useless. The queries are evaluated in the listed order, so in most cases it doesn't matter too much.

It will also try some additional rewrites, such as concatenating terms under certain circumstances, and breaking them apart in others.

"TRS80" will produce "trs80" and "trs_80", and conversely "TRS-80" will also yield a "trs80"-term.

"Raspberry Pi 2" will produce

raspberry_pi_2
raspberrypi, 2
raspberry, pi_2
raspberry_pi, 2
raspberry, pi, 2

## Query Refinement

The next big problem has been that the search engine has been spectacularly good for narrow topics. If your search term was one topic, and that topic was broadly within the range of things covered by the index, oh boy did it occasionally produce some stellar results. 

If you however tried to refine the results by adding more search terms, the results often drastically got worse. 

For example: If you searched for "graph algorithms", you found a beautiful page on graph algorithms, including Strongly Connected Components. If you searched for "graph algorithms SCC", that page ranked very low, and instead most of what floated to the top was junk. That's pretty weird. It took a while to figure out what was going wrong.

While the search engine has gotten reasonably good at figuring out which search terms are relevant to a document, it was bad at figuring out which search terms are relevant to a query. This is fine if there is only one term, but for multiple terms, things fall apart. It would, in short, use the relevance of the least relevant term (with regard to the document) to rate the relevance of the search result.

If we consider a query like "C++ tutorial", ignoring N-grams, we can see that these terms are not equal. Ideally we'd like all terms to be highly relevant, but in the case that they aren't, it's much better to show results that are highly relevant to "C++" but only briefly mentions "tutorial", than terms that are highly relevant to "tutorial", but only briefly mention "C++".

A way of using this is to consider the term frequency of the search term across all documents. Terms that occur often are probably less informative than terms that are rarer. 

Ideally you would use something like Okapi BM25, but the information that ranking function requires is not something that is readily available the way the search index is currently implemented, so I've had to, using what I have available, cook up something that behaves in a similar way; a average weighted on in inverse document frequency.

Both these changes are pretty rough, and still need some more polish, but I do think they are steps in a good direction. At the time of writing, these features are incubating, and only fully enabled for the 'Experimental' index. When I'm happy with how it works, I will apply it to the other indices.

## See Also

* [https://encyclopedia.marginalia.nu/wiki/TF-IDF](https://encyclopedia.marginalia.nu/wiki/TF-IDF)
* [https://encyclopedia.marginalia.nu/wiki/Okapi_BM25](https://encyclopedia.marginalia.nu/wiki/Okapi_BM25)

