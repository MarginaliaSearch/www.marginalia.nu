+++
title = "A Jaunt Through Keyword Extraction"
date = 2021-11-11
section = "blog"
aliases = ["/log/37-keyword-extraction.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


Search results are only as good as the search engine's ability to figure out what a page is about. Sure a keyword may appear in a page, but is it the topic of the page, or just some off-hand mention? 

I didn't really know anything about data mining or keyword extraction starting out, so I've had to learn on the fly. I'm just going to briefly list some of my first naive attempts at keyword extraction, just to give a context.

* Extract every keyword.

* Extract recurring N-grams.

* Extract the most frequent N-grams, and N-grams are Capitalized Like Names or occur in titles.

* Use a dictionary extracted from Wikipedia data to extract names-of-things.

These approaches are ignorant of grammar, and really kind of blunt. As good as the keywords they find are, they also hoover up a lot of grammatical nonsense and give a decent number of false positives. Since they lack any contect, they can't tell whether "care" is a noun or a verb, for example.

Better results seem to require a better understanding of grammar. I tried Apache's OpenNLP, and the results were fantastic. It was able to break down sentences, identify words, tag them with grammatical function. Great. Except also extremely slow. Too slow to be of practical use.

Thankfully I found an alternative in Dat Quoc Nguyen's RDRPOSTagger. Much faster, and still much more accurate than anything I had used before. In practice I usually prefer dumb solutions to fancy machine learning. The former is almost always faster and usually more than good enough.

Armed with a part-of-speech tagger, and most of the same regular expressions used before to break down sentences and words, allowed some successful experimentation with standard keyword extraction algorithms such as TF-IDF and TextRank. 

TF-IDF is a measure of how often a term appears in a document in relationship to how often it occurs in all documents.

TextRank is basically just PageRank applied to text. You create a graph of adjacent words and calculate the eigenvector. It's fast, works well, and shares PageRank's ability to be biased toward a certain sections of the graph. This means it can be used to extract additional useful sets of keywords, such as "keywords related to the words in the topic".

How often a keyword occurs in these various approaches to keyword extraction can be further used to create tiered sets of keywords. If every algorithm agrees a keyword is relevant, hits for such a keyword is prioritized over keywords that only one of the algorithms considers important.

There is a considerable amount of tweaking and adjusting and intuition involved in getting these things just right, and I've been fussing over them for several weeks and could probably have kept doing that for several more, but eventually decided that it has to be good enough. The improvements are already so large that they ought to provide a significant boost to the relevance of the search results.

I'm almost ready to kick off the upgrade for the November upgrade. Over all it's looking really promising.



## See Also

* [/log/31-ngram-needles.gmi](/log/31-ngram-needles.gmi)
* [/log/26-personalized-pagerank.gmi](/log/26-personalized-pagerank.gmi)
* [/log/21-new-solutions-old-problems.gmi](/log/21-new-solutions-old-problems.gmi)

* [https://github.com/datquocnguyen/RDRPOSTagger](https://github.com/datquocnguyen/RDRPOSTagger)
* [The Page Rank Citation Algorithm: Bringing Order To The Web](http://ilpubs.stanford.edu:8090/422/1/1999-66.pdf)
* [Text Rank: Bringing Order into Text](https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf)
* [https://encyclopedia.marginalia.nu/wiki/TF-IDF](https://encyclopedia.marginalia.nu/wiki/TF-IDF)