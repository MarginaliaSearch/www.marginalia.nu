+++
title = "Index Optimizations"
date = 2021-07-23
section = "blog"
aliases = ["/log/06-optimization.gmi"]
draft = false
categories = []
tags = ["programming", "search-engine"]
+++


>   Don't chase small optimizations

Said some smart person at some particular time, probably. If not, he ought to have; if worse comes to worst, I'm declaring it now. The cost of 2% here and 0.5% there is high, and the benefits are (by definition) low.

I have been optimizing Astrolabe, my search engine. The different kind of Search Engine Optimization. I've spent a lot of time recently doing soft optimization, improving the quality and relevance of search results, to great results. I'll write about that later.

This post is all about about war stories.

The search index simply grew beyond what the code could deal with. The characteristic behavior of dealing with very large amounts of data is that whatever you're doing works well, until you hit a brick wall, where it suddenly doesn't work at all. This has happened at a few times already.

# Problem #1 - Wildly random writes

Part of my the search engine reads a list of URLs and words. I'm presenting a scheme of the file here so that you can get a grasp for the layout. Imagine letters are URLs and and numbers are words here. In reality it's all integers but we can pretend it's not.

```
(A) 1 5 7 8 (B) 3 2 (C) 1 5 7 (E) 2 8 9 etc...
```

This is converted into two files that make up an implicit look-up table, and a sorted list of URLs grouped by which words they contain. I'll attempt to illustrate the layout.

First the two files, horizontally and side-by-side. Presented vertically is the value the lookup table will arrive at for each index (1-indexed).

```
  0 0     2   3   4 4   5 5     7     9    WORDS (position in URLs)
  | | A C | B | B | | C | | A C | A E | E  URLS
0 + |     |   |   | |   | |     |     |
1 --+     |   |   | |   | |     |     |
2 --------+   |   | |   | |     |     |
3 ------------+   | |   | |     |     |
4 ----------------+ |   | |     |     |
5 ------------------+   | |     |     |
6 ----------------------+ |     |     |
7 ------------------------+     |     |
8 ------------------------------+     |
9 ------------------------------------+
```

So to find URLs that contain word '7', you would look at the range in the urls file starting at words[7] and ending at words[8]; in this case, that's indices 5 and 7; the so words are A and C.

It's confusing, but what matters is this: The input file is typically of the order of a few gigabytes, and the output files can be in the tens of gigabytes. To rearrange the data in this fashion requires a lot of random writes, the order of the input file doesn't correlate with the order of the output file, and it's too much data to buffer in memory.

The destination is a consumer grade SSD. These SSDs do not deal well with tiny random writes at all. It's just too slow.

The first order solution I was using was to mmap the file and let the operating system sort out the write order, which worked until it suddenly didn't. Conversion of a large index, a process that repeats this process 20 times, usually took around an hour. That is below the pain threshold. This is run once or twice a day while actively crawling the web, and not having much of an impact on the operations of the search engine, so that's tolerable.

Then out of the blue, it stopped taking an hour, the conversion time increased to over 24 hours.

What had happened is that the file had gotten too big to entirely keep in memory, and consequently the random writing pattern incurred extreme thrashing, with ceaseless page faults.

The file in the example would write in this order:

```
A_________
A____A____
A____A_A__
A_B__A_A__
A_BB_A_A__
ACBB_A_A__
ACBBCA_A__
ACBBCACA__
ACBBCACAE_
ACBBCACAEE
```

The solution was to first write >writing instructions< in a series of files on disk, that is arranging them in buckets based on their destination address in the final file. This effectively increases the amount of data to be written by 150%, but that's fine as long as it's fast. (Nobody look too carefully at the SMART values  for the SSD I'm using exclusively as a working space for these index files)

The instructions, schematically, look like this:

File 1: A@0 B@2 B@3 C@1
File 2: A@5 C@4 C@6
File 3: A@7 E@8 E@9

These can be evaluated on a by-file basis to organize the writes to eliminate thrashing, and so the writing speed is back to being comparable with the original solution.

The instructions above would evaluate like this

```
A_________ - File 1 -
A_B_______
A_BB______
ACBB______
ACBB_A____ - File 2 -
ACBBCA____
ACBBCAC___
ACBBCACA__ - File 3 -
ACBBCACAE_
ACBBCACAEE
```


# Problem #2 - A Very Large Dictionary

A few days later I ran into a problem with keeping the search term dictionary in memory. The dictionary is a one-way mapping between a string (a word), to a unique integer id. These IDs are the "words" from the previous section.

The index crashed when the dictionary was approximately 380 million terms. This needs to be very fast, and there aren't a lot of canned solutions that deal with the particular scenario. I've been using GNU Trove's custom hash tables. From experimentation, the B+-trees popular in SQL databases don't deal gracefully with this type of usage. The disk size of the dictionary was 6 Gb, but the memory footprint was closer to 24 Gb and the dreaded OOM-killer kept killing my process.

## Java is wasteful

The thing when you have of order a billion items is that evey byte translates to a gigabyte of memory. Normally a few bytes here and there really doesn't matter, but in this domain, you need to be extremely frugal.

First I needed to work around the fact that Java has a 16 byte object header associated with every object. The solution was to allocate off-heap memory (an extremely unpleasant interface that allows some interface to basic malloc()-memory) rather than 380 million byte[]-instances. I also ended up implementing my own hash table and memory allocator specifically for this  scheme.

This shaves 4 or so Gb off the memory footprint. Down to 20 Gb for 6 Gb of data. Better, but still not good.

(Yes, I really should re-implement this part of the search engine in a more suitable language like C++, I probably will some day, but not today.)

## Text is redundant

The dictionary entries themselves are single-byte encoded strings, sometimes joined by underscores to represent sequences of words. The heading of this section would produce the terms "text", "is", "redundant", "text_is", "is_redundant", "text_is_redundant". That's a lot of redundancy.

```
0  text
1  is
2  redundant
3  text_is
4  is_redundant
5  text_is_redundant
```

As an observation based on what the data looks like, there are more joined words than regular words. One would indeed expect there to be more permutations of the items of a set than items in the set for sets that are larger than two items. This would imply two avenues of improvement:

### Reduce the number of single words

Not much to do here, I implemented better language identification based on dictionary overlap with 1000-most-common-words lists for the target languages. The search engine targets English, Swedish and Latin; the languages I can understand. This is in part to reduce the dictionary to a feasible size, and in part because I can't quality control search results I can't read.

Languages that join words without hyphens are especially problematic. Looking at you, Germany; I found the first instance of "programmierungsmodelle" after over 300 million dictionary entries.

### Optimize how joined words are stored

Perhaps a way forward is using the fact that the dictionary already is a mapping from string to integer, to compress the data. For some function F, the data can be stored as

```
0 "text"
1 "is"
2 "redundant"
3 F(0,1)
4 F(1,2)
5 F(3,4)
```

As long as the output of F is in a separate binary namespace from regular strings, that's fine. To this end, integers need to be prefixed by a marker byte, luckily there's 32 available items at the bottom of the ASCII table I used that are guaranteed to never appear in the dictionary entries. Integers are 4 bytes each though, and the marker byte is another, so this would only be helpful for strings that are in excess of 9 bytes.

But! These integers are often smaller than a full integer, you can represent all the integers in the example with <= 3 bits. You could store the entire pair in a single byte if you really try, like so:

F(0,1) = Marker+(0000001)
F(1,2) = Marker+(0000110)
F(3,4) = Marker+(0011100)

The 32 available marker bytes can then encode how many bits from the right the break between numbers are. This is extremely fiddly programming and I freely admit it took several hours to iron out all the corner cases.

I got it right in the end, mostly thanks to a comprehensive battery of unit tests, and suddenly the size of the dictionary binary data was almost halved.

Likewise, I devised a few schemes for representing integers in the smallest necessary binary format, helpful as there are a lot of random integers floating around on the internet. There are a few more schemes you could implement, but then you are chasing small percentages and that's not worth it.

Actually evaluating these compressed byte schemes would be pretty slow, but luckily there's no need for that. The bytes are used exclusively as keys for the dictionary. All they need to be is a unique representation of the input that is cheap to calculate.

In all, this reduced the memory footprint of the dictionary by 8Gb, from in excess of 24Gb to 16Gb; and the entries seem to be encoded at an average of 6 bytes per entry, down from 15. If anyone thought it would be "good enough" to just calculate a hash wide enough to ensure there's probably no collisions, then it would almost certainly be more expensive. Even an 10 byte hash would feel pretty sketchy for a billion+ items (10^-7 collision rate).

This was helpful, but the precious cherry on top is realizing the applicability of Zipf's law. Preparing the dictionary with a list of dictionary items in order of most common occurrence gives a compression ratio of 60-70%, since the bit-length of the index effectively becomes inversely related to the probability of finding the word! The most common words become the least amount of bits!

GZip compresses the old data by 63% (that's the ballpark my own compression arrived at!), and the new one by 21%. That's not at all bad given how cheap it is.

--

About half of this is live and running on the search engine right now, the rest will probably go live next week.

## Links and further reading

* [Zipf's Law](https://web.archive.org/web/20021018011011/http://planetmath.org/encyclopedia/ZipfsLaw.html)

* [Astrolabe Part 1](/log/01-astrolabe.gmi)
* [Try the Search Engine](https://search.marginalia.nu/)
