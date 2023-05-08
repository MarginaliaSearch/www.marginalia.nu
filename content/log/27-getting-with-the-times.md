+++
title = "Getting with the times"
date = 2021-10-06
section = "blog"
aliases = ["/log/27-getting-with-the-times.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


Since my search engine has expanded its scope to include blogs as well as primordial text documents, I've done some thinking about how to keep up with newer websites that actually grow and see updates. 

Otherwise, as the crawl goes on, it tends to find fewer and fewer interesting web pages, and as the interesting pages are inevitably crawled to exhaustion, accumulate an ever growing amount of junk. 

Re-visiting each page and looking for new links in previously visited pages is probably off the table, that's something I can maybe do once a month.

Thinking about this for more than a few minutes, the obvious answer is syndication. Most blogs publish either RSS or Atom feeds. They are designed to let you know when there has been an update, and pretty trivial to parse especially if you are just looking for links.

Extracting a bunch of RSS feeds from previously downloaded web pages was an easy enough affair, took about an hour to chew through some gigabyte of compressed HTML and insert the result into a database table. 

It struck me that this would be incredibly vulnerable to search engine manipulation if I just crawled every link I found in the RSS feeds in fair and democratic order. Someone content mill could just spew out thousands of articles per day full of links.

There does seem to be some easy ways of limiting the potential damage:

* Only consider documents from the same domain.
* Reduce the number of documents per visit to a low number (currently 6).
* Don't count these document towards the link database. 

Since the goal is to add new documents without allowing websites to use the mechanism for manipulating the search rankings, this seems like a good set-up.

The next problem is a problem of priority. I identified 290,000 RSS feeds, and I don't want to visit them all as 90% of what I would get is crap. Sturgeon's Law seems to apply to the Internet as much as anywhere. 

If only there was some sort of ranking algorithm for websites... yeah. Of course! Limiting the RSS spider to the top 15,000 domains according to BlogRank cuts out *most* of the crap, while isolating exactly the sort of websites that I would like to keep refreshed.

It should take approximately a day to run through the RSS feeds. That also seems a reasonable poll rate. 

It's an experiment. We'll see how it turns out. If it works out, maybe it will be able to read about the Facebook outage in a few days...

