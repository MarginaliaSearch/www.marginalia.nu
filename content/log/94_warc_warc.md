+++
title = "WARC'in the crawler"
date = 2023-12-20
tags = [ "search-engine", "nlnet" ]
+++

The Marginalia Crawler has seen improvements!  A long term problem with the crawler design is
that if for whatever reason the crawler shuts down, then it needs to re-start fetching whatever 
domains it was currently traversing during the termination from zero.

This isn't fantastic, since not only does crawling a website take a fair bit of time,
it's a nuisance for the server admins to re-crawl stuff that was already fetched, and
a real liability for ending up in robots.txt or some iptables ruleset. 

To get around this, I decided to modify the crawler to write a sort of flight recorder-eseque
log of what's going on.  There's actually already a format very well suited to this, [WARC](https://iipc.github.io/warc-specifications/specifications/warc-format/warc-1.1/);
originally out of the Internet Archive project, it's essentially an annotated version of the
HTTP traffic, and has nice recovery properties in terms of partial writes and so on.

WARC is also a good choice because it adds some degree of interoperability with other crawlers
and projects. 

Said and done, this turned out to be relatively straightforward.  I used a library called
jwarc to do most of the heavy lifting.  In this case jwarc was a bit of an awkward fit, not a 
fault of the library, just a minor incompatibility with the level of operations, where much of 
Marginalia's crawling works at a higher abstraction level and access to http protocol details 
isn't always very easy, meaning some of the headers and handshakes is re-constructed after the 
fact.

I probably could have rolled my own WARC library to avoid some of this work, but I'm not sure
the juice is worth the squeeze.  It works well enough for now.

This change has been somewhat fraught with gotchas, since the needs for a web archiving project,
and the needs of a search engine crawler isn't always 100% exactly the same, so some minor extensions 
were necessary.   The WARC standard seems to have been drafted with the insight that this is likely 
going to be a common scenario, and is requires that processing software ignores records it doesn't 
recognize.

The crawler, since a while back, uses old crawl data to produce conditional requests to avoid re-fetching
documents that haven't changed.  The new records are needed to persist the old version in the WARC file,
which is necessary information for the crawler when replaying the WARC.

I had some idea that maybe I can replace the crawl data storage format with WARC altogether,
but this didn't pan out since the WARC format is too chatty.  With the "default" gzip compression,
it's about 4x larger than the zstd-compressed JSON it was intended to replace.  Even re-compressing
the WARC data with zstd meant the files were twice as large.

There is still solid reasons to try to get rid of the JSON format, since parsing long strings 
in JSON is incredibly inefficient.  JSON doesn't have any way of telling how long the 
string is before hand, so it keeps getting copied from buffer to buffer as it grows.  In 
practice these strings, since they contain entire HTML files, are atypically long, meaning 
the JSON parser's default buffer sizes are very inadequate.  It can't really scan ahead to size 
the string before allocating the buffer either, since this is a compressed data stream!

So instead of storing the data as WARC, I opted to go for parquet.  Parquet is great for most 
cases when you have relatively homogeneous data.  In terms of size on disk there is no real 
difference, but access speeds are much improved.

A point of potential concern is that this change increases the amount of crawler disk I/O a fair bit, 
but I think it should be fine.  What's written is compressed, and disk bandwidth, even though it gains
a bit of redundancy with this alteration, is still significantly faster than network I/O, ... and virtually all 
access patterns involved are sequential.

In general the change has been very good for the crawler, which was arguably one of the messier
parts of the code base owing to a bunch of features that weren't adequately integrated, especially
the [revisit logic](https://github.com/MarginaliaSearch/MarginaliaSearch/blob/master/code/processes/crawling-process/src/main/java/nu/marginalia/crawl/retreival/revisit/CrawlerRevisitor.java).  

This has improved quite a lot... with one notable exception.

The old JSON format is still needed to provide a path of migration, because previous crawls are consulted 
when re-crawling a domain (for ETags etc.), which puts the temporarily at a sort of awkward point where 
it needs to support both the legacy JSON format, WARC, and the new parquet format for crawled document data. 
All  of these are fairly heterogeneous so a fair bit of shimming is necessary to support each representation.  

This will resolve itself after the next round of crawling, slated to start mid January sometime,
after which the legacy format can be scrapped altogether.  The next crawl will also be a bit of a 
shakedown round for these changes.  You can build tests and run limited crawls on www.marginalia.nu, 
but experience tells me that nothing quite compares to production when it comes to discovering 
crawler issues...

There hasn't been a release for Marginalia Search git repo since sometime in October, but this is largely
due to the sheer quantity and scope of the changes that have been made, even though what's in production
has been updated, it hasn't quite felt polished.  The plan is to release after the next crawl.  