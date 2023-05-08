+++
title = "Astrolabe - The October Update"
date = 2021-10-01
section = "blog"
aliases = ["/log/25-october-update.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


* [https://search.marginalia.nu](https://search.marginalia.nu)

The October Update is live. It introduced drastically improved topic identification and an actual ranking algorithm; and the result is interesting to say the least. What's striking is how much it's beginning to feel like a search engine. When it fails to find stuff, you can kinda see how.

I've played with it for a while now and it does seem to produce relevant results for a lot of topics. A trade down in whimsical results but a big step up if you are looking for something specific, at least within the domain of topics where there are results to find.

What really cool is how non-commercial a lot of the results are. If you search for say "mechanical keyboards", at the time of writing, 9 out of the 10 first entries are personal blogs. The Google result is... uh... yeah, a good example of why I started this project.

## Ranking Algorithm Overview

The ranking algorithm is a weighted link-count, that counts distinct links on a domain-by-domain basis given that they come from sites that have been indexed sufficiently thoroughly. 

It really does seem to produce pretty decent results. Here are the current top 15 domains.

```
+-------------------------------+---------+
| URL_PART                      | QUALITY |
+-------------------------------+---------+
| www.fourmilab.ch              | 92.8000 |
| www.debian.org                | 91.8000 |
| digital.library.upenn.edu     | 77.7000 |
| www.panix.com                 | 77.1000 |
| www.ibiblio.org               | 75.7000 |
| users.erols.com               | 73.6000 |
| www.openssh.com               | 70.5000 |
| xroads.virginia.edu           | 66.7000 |
| www.openbsd.org               | 65.4000 |
| www.levity.com                | 63.4000 |
| www.catb.org                  | 61.7000 |
| www.webspawner.com            | 59.9000 |
| www-personal.umich.edu        | 59.0000 |
| onlinebooks.library.upenn.edu | 55.7000 |
| www.postfix.org               | 49.1000 |
+-------------------------------+---------+
```

## Walls of Text

A strange thing that's happened is that it seems to really strongly prefer long form wall-of-text style pages, especially with very little formatting. I'd like to tweak this a bit, it's looking a bit too 1996 and this isn't supposed to be a "live" Wayback machine.

Part of this may be because the search engine premieres results where keywords that appear the most frequently in a page, especially when they overlap with the title. It does trip up a lot of keyword stuffing-style SEO, since if you put all keywords in a page, then nothing sticks out. However, in shorter pages, topical words may not appear sufficiently often.

I've implemented optional filtering based on HTML standards, and I think with some adjustments I might be able to just add a "modern HTML" filter that picks up on stuff that looks like it's written after y2k based on the choice of tags and such. Unfortunately just going by DTD doesn't seem to work very well, as it appears many have "upgraded" their HTML3 stuff to HTML5 by changing the DTD at the top of the page and keeping the page mostly the same. I'm gonna have to be cleverer than that, but it feels reasonably doable.

## Red October?

I received some justified complaints that there were a bit too much right wing extremism in the search results in the August index. I haven't removed anything, but I've tweaked relevance of some domains and it does seem to have made a significant difference.

I did the same for some very angry baptists who kept cropping up telling video game fans they were going to burn in hell in eternity if they didn't repent and stop worshiping false idols. 

My main approach to this is to go after the stuff that is visible. If you go out of your way to look for extremist stuff, then you are probably going to find it. However if this type of vitriol shows up in other searches it is a problem.

The commies seem less likely to crop up in regular search results, so I haven't gone after them quite as hard. This may give the current state of the search engine a somewhat left-wing feel. One could argue it does compensate for the far-right feel of the September index.

Ultimately I really don't care about politics.  I think loud political people are exhausting.  Maybe you care about politics, that's entirely fine; I probably care about some things you don't want to hear about as well.  I just don't want hateful tirades showing up in any search results, whether they are left, right, religious, atheist, pro-this, anti-that.  These angry people feel so strongly about their convictions they think they are entitled to impose on everyone whether they want to listen or not.  It's really the last part I disagree with.

## Link Highlights

To wrap things up, I wanted to highlight a few cool links I've found these last few days. Topically they are all over the map. Just see if you find something you enjoy.

* [http://papillon.iocane-powder.net/](http://papillon.iocane-powder.net/)
* [https://meatfighter.com/castlevania3-password/](https://meatfighter.com/castlevania3-password/)
* [http://www.sydlexia.com/top100snes.htm](http://www.sydlexia.com/top100snes.htm)
* [https://www.tim-mann.org/trs80/doc/Guide.txt](https://www.tim-mann.org/trs80/doc/Guide.txt)
* [https://schmud.de/](https://schmud.de/)

