+++
title = "Rendered static HTML"
date = 2021-08-13
section = "blog"
aliases = ["/log/13-static-html.gmi"]
draft = false
categories = []
tags = ["web-design"]
+++


The technological choices we make determine the rules we have to abide by. 

If every page load incurs hundreds of database calls on the server, and 30 seconds of javascripting on the front-end, then obviously you need to reduce the number of page loads to a minimum. They are frustrating for the user and expensive for the server. This makes the front-end even more slow and stateful, and so the urgency for reducing page loads increases even further.

So what if we don't do any of that? What if we just serve static HTML instead? For the server it's such a lightweight even a raspberry pi can hold the fort at moderate traffic, and on the front-end it's just as fast. 

Of course, rendering HTML isn't free. Depending on how much data we're talking about, it can take time. But it's time you spend once, or at least infrequently. Not only is the result faster, it's better for the environment. We can host more stuff on less server, and the clients don't need to use nearly as much wattage presenting it. As long as your data is fetched more often than it is altered, it's an improvement. 

The sacrifice is of course all those small alterations, modifying content is what becomes expensive, everything else is virtually free. This means you can't afford to change the content based on the visitor's history. Everyone gets the same page. In this paradigm, you need hardware in proportion to the rate your content is mutated, not the amount of content, or really even the number of users. This since you can cache the content extremely cheaply using ETags. 

What I want to show is the profound downstream effects of making a different design decision. A piece of counterfactual web-design history. 

## Case 1: Reddit

I have experimented with this approach for a while, and among my first attempts was a front-end for reddit. It's a relatively kind use case, where I use their APIs to fetch the few subreddits I frequent, and render the threads and comments and keep the results in memory, backed by a disk-based long-term storage for fault tolerance. I also wrap their submission API, posts to which triggers an immediate re-rendering of the affected thread or subreddit, giving the illusion that it's always fresh when it's in practice usually a maybe 10 minutes behind the real deal. 

It's overall pretty fast and light. "Real" reddit has approximately an 8 Mb payload. My front-end has payload usually sits around 1-2 Kb. It pulls some stylesheets and a font or two, still rarely going above 50 Kb. 

Of course my design is also a lot more stripped down, aiming for a degree of functionality somewhere between your average mailing list and a pre-2000s internet forum. What I originally wanted to explore was how the reddit experience would change if you removed votes, direct messages and most images, and made it a pure text-based discussion board. The result has a very different feel to it, when you must judge each comment for itself, without the ability to see how other people have judged it.

## Case 2: Wikipedia

Why not go for broke, right? I've harped about the questionable design choices of wikipedia before, and while they do let you inject CSS (if you log in), page loads are still incredibly slow and it's bringing me a lot of frustration. 

They do license their page content under CC-BY-SA, so why not use that license to impose my flavor of design improvements and produce a version of wikipedia designed with the singular purpose of making it as easy to read as possible, purging it of inline links and footnotes, images and most tables. 

Wikipedia doesn't want you to scrape their live site because it's apparently very expensive to render. 

How delightfully apropos! I guess that is what's up with the slow page loads. 

A way around that is that they do offer data dumps for download in various formats. So I grabbed a ZIM archive--that's an archive format for rendered wikipedia readers that's relatively standardized--and found an abandoned library for reading such files, tinkered with it a bit because it was apparently written in the time of Hildegard of Bingen and so read the file data a single byte at a time. The library was as a result about 100 times slower than it needed to be. 

After that I wrote a program that extracts every HTML page, subjects them to a pretty severe DOM-massage that removes most inline links and stuffs them at the end of the page. Then I write them as gzip-compressed HTML to disk. The output is for the most part pristine HTML. You don't even need a browser to read it. Netcat is plenty. 

Formulas were a bit tricky, and the best solution I could find was rendering them into PNG and inserting them directly into the HTML. As long as nobody tells Donald Knuth, I think I may get away with this cruel affront to typesetting mathematics ;-)

Rendering takes about 24 hours and produces some 14 million files, 60 Gb in total. I have no doubt it could be done faster, but a day's worth of cooking really isn't even that bad since these dumps come out about once every six or so months.

### Thoughts

Two things become apparent after using the scrubbed encyclopedia for a while.

The first is that it really is a lot easier to read once you remove all the points of distraction. I start reading it like a book. I've gotten stuck reading articles in a way I rarely do in Wikipedia. I've learned quite a lot too. This has been my hypothesis since before I embarked on this project, that inline hyperlinks and images do more to disrupt readability than to enhance it.

The second observation is more surprising: I find it far more apparent when I don't fully grasp a topic. It is as though hyperlinks makes us think that information is available to us, and because of that, we estimate that we essentially already understand the topic, beacuse we could find out later. 

This is of course not sound logic at all, but I think that is what happens when we see an underlined word we aren't quite sure what it is. So we keep reading as though we did know, and never go back to click the link, because if you click every link, you won't get past the first sentence in any article.

The experience when reading the scrubbed encyclopedia is one of needing to take notes of things to look up later, one of barely understanding the text even in areas I'm quite well versed, even pages I've previously read in Wikipedia.

I wonder if this effect is part of why there are so many experts these days. Covid breaks out, and everyone is suddenly an immunologist. IPCC report drops and everyone is suddenly a climate scientist. If there's a war, everyone is a general; if someone wants to lose weight, everyone is an expert on that too (even if they've never tried themselves). Nevermind the fact that it takes a decade of studies to even get a PhD, nobody seems to need any of that.

## Links

* [On The Linkpocalypse](/log/00-linkpocalypse.gmi)
* [Writing For Reading](/log/03-writing-for-reading.gmi)

* [https://reddit.marginalia.nu/](https://reddit.marginalia.nu/)
* [https://encyclopedia.marginalia.nu/](https://encyclopedia.marginalia.nu/)
* [https://encyclopedia.marginalia.nu/wiki/Hildegard_Of_Bingen](https://encyclopedia.marginalia.nu/wiki/Hildegard_Of_Bingen)

* [https://dumps.wikimedia.org/](https://dumps.wikimedia.org/)

