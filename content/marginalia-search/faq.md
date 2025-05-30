+++
title = "FAQ"
date = 2023-03-28
section = "marginalia-search"
aliases = ["/projects/edge/faq.gmi"]
draft = false
categories = ["docs", "outdated"]
+++

<div style="border: 1px solid red; padding-left: 1ch; padding-right: 1ch;">

**This information is outdated** 

The marginalia search project info now lives on [about.marginalia-search.com](https://about.marginalia-search.com/).

</div>

# What is this search engine's name?

Let's call it Marginalia Search as that's what most people seem to do.

There is some confusion, perhaps self-inflicted problem as I'm not really into branding and logos, and to make matters worse I've used a lot of different internal names, including Astrolabe and Edge Crawler. But most people seem to favor "marginalia search". Let's just not worry too much about what the "real" name is and use what gets the idea across.

# I'm working on something cool, may I have some data, or API access?

API access: 
https://api.marginalia.nu/

Select data exports: https://downloads.marginalia.nu/exports/ 

If you have other needs, send an email to kontakt@marginalia.nu and we can talk about it.

# Why do you only support English?

I'm currently focusing on English web content. In part this is because I need to limit the scope of the search engine. I have limited hardware and limited development time. 

I'm just one person, and I speak Swedish fluently, English passably, and understand enough Latin to tell my quids from my quods, but the breadth of my linguistic capability ends there. 

As such, I couldn't possibly ensure good quality search results in hundreds of languages I don't understand. Half-assed internationalization is, in my personal opinion, a far bigger insult than no internationalization. 

# What is the hardware and software stack? 

The software is custom built in Java. I use MariaDB for some ancillary metadata.  
The code is open source and available at https://git.marginalia.nu/.

Up until October 2023, the search engine ran on PC hardware on domestic broadband,
but is being migrated onto a proper server. 

# How big is the index?

It depends when you ask, but the record is about 300 million documents [in 2024]. In terms of disk size, we're talking approximately a terabyte.

Index size isn't a particularly good metric. It's good for marketing, but in practice an index with a million documents that are all of high quality is better than an index with a billion documents where only a fraction of them are interesting. Sorting the chaff from the wheat is a much harder problem than just building a huge pile of both.

# Where is the data coming from? 

The search engine does its own crawling.

# Is this going to replace Google?

No, and it's not trying to. It's trying to complement Google, by being good at what they are bad at. What the world needs is additional search options, not a new top dog.

# Is this open source?

Yes. The sources are AGPL licensed and available at 

[https://git.marginalia.nu/](https://git.marginalia.nu/)

# What do I do if I a query pops up anything really tasteless or illegal?

Send me an email and I'll see if I can't block the domain. You can also use the 'info' link under the search result and file a report from there.
