+++
title = "Shaking N-gram needles from large haystacks"
date = 2021-10-22
section = "blog"
aliases = ["/log/31-ngram-needles.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


A recurring problem when searching for text is identifying which parts of the text are in some sense useful. A first order solution is to just extract every word from the text, and match documents against whether they contain those words. This works really well if you don't have a lot of documents to search through, but as the corpus of documents grows, so does the number of matches.

It's possible to bucket the words based on where they appear in the document, but this is not something I'm doing at the moment and not something I will implement in the foreseeable future.

A next order solution is to consider N-grams of words, that is pairs, triples, quadruples, etc. On paper this is a great idea, as it allows you to basically perform limited free text search. The caveat is that the number of potential N-grams grows extremely quickly, and a very small amount of them are ever going to be useful; this makes enumerating them an effective impossibility (and enumeration is necessary to save space and reduce query time).

Extracting some N-grams from the previous sentences, you can see that there are some possibly useful for search: "potential N-grams", "free text search, "next order solution"; they refer to something, but many more N-grams don't mean anything, "are ever", "of them are", "is that", "of potential". They are numerous and they are word salad taken in isolation.

One way of reducing the number of N-grams to a reasonable level is to look for repetition in a document, or things that are Capitalized As Names. Both of these methods will retreive very useful needles from the haystack that make very good search results. The problem is that this leaves a lot of meat on the bone. This is the bulk of my current keyword processing, and the result has been just such: The results are often good but usually few.

Returning to the impossible task of enumerating all possible N-grams, maybe we can somehow reduce the scope. Maybe if we had a list of the sort of N-grams that refer to things, places, people; we could escape the combinatorial hellscape that enumerating all possible word combinations. This extends beyond nouns, and includes things like "The Man from UNCLE", "The Word of God", "Dancing Shoes". Maybe a grammarian somewhere has a good word for this class, but let's just call them keywords. A noteworthy part is that these types of noun-like sentence fragments seem to have less ambiguity than words alone. A word like "chair" can both be something you sit on, and a boardmember. Reducing ambiguity is always useful for a search engine. 

One approach to reducing the number of N-grams to consider is to grab the list of N-grams found through the repetition method, and to look for them in all documents. This does effectively reduce the scope, but the method has flaws. It tends to bias toward certain segments, especially religious terminology, since it is very common to paraphrase scripture in those circles, which creates repetition. Another concern is that it vulnerable to manipulation through keyword spam.

The other model is to create a keyword lexicon from an external source. There are many possible sources, but it turns out that Wikipedia is very useful for this. Most of their inline links contain viable keywords, in all hundreds of millions of samples, so it is quite feasible to grab the keywords that appear more than a couple of times. That is in itself relatively straightforward from an OpenZIM dump. Sideloading additional keywords from tens of millions of documents will take a while, but I'm doing it as an experiment to see if this approach needs adjustment before doing a full rebuild. 

Twenty four cores on full blast and a load average in the mid 30s for a couple of days is totally fine <.<



## See Also

* [/log/21-new-solutions-old-problems.gmi](/log/21-new-solutions-old-problems.gmi)

## Appendix A - Reusing Previously Extracted Words

Note: This algorithm ignores single words

```
music_magazine_may_1994
recordings_of_die_zauberflöte
the_absolute_sound_issue
the_gramophone_january_2006
american_record_guide_march
bbc_music_magazine_february
x_window_system
iroquois_county_genealogical_society
omega_opera_archive
international_opera_collector
```

## Appendix B - Wikipedia 

```
rolex_sports_car_series
wellington
metropolitan_opera_radio_broadcasts
red_cross
anime
composer
the_saturday_evening_post
pitcher
court_of_appeal
indianapolis
microsoft
```