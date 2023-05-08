+++
title = "The Astrolabe Part I: Lenscraft"
date = 2021-07-07
section = "blog"
aliases = ["/log/01-astrolabe.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


Something you probably know, but may not have thought about a lot is that the Internet is large. It is unbelievably vast beyond any human comprehension. What you think of as "The Internet" is a tiny fraction of that vast space with its billions upon billions of websites.

We use various technologies, such as link aggregators and search engines to find our way and make sense of it all. Our choices in navigational aides also shapes the experience we have of the Internet. These convey a warped sense of what the Internet truly is. There is no way of not doing that. Since nothing can communicate the raw reality of the internet to a human mind, concessions need to be made. Some content needs to be promoted, other needs to be de-emphasized. An objective rendering is a pipe dream, even a fair random sample is a noisy incomprehensible mess.

It is a common sentiment on the small web that the Internet has changed, somehow. It isn't what it used to be. It's too commercial, there are too many ads, nobody is being authentic, pages take forever to load, the blogosphere is dead, there's no substance anymore just pictures and hot air, and variations on this theme. I'm going to propose a different interpretation: Maybe it's not the Internet that has changed, but the lenses you are viewing it through. Google has changed. Reddit has changed. Facebook has changed. Twitter has changed. Maybe the Internet has changed too, but what if it hasn't, what if it is still out there?

Google makes its money from storefronts and ads. If you were in their shoes, wouldn't you also promote search results that have ads, or are storefronts? Facebook makes its money from ad impressions. If you were in their shoes, wouldn't you also promote content that maximizes idle scrolling? I'm not asking whether this is good, or for the best, or even ethically defensible; I'm saying it makes perfect sense to, given their incentives, to create lenses for the internet that emphasizes behaviors that serve their economic interests.

Making matters worse, entire industries--much shadier still--have arisen to exploit the algorithms used by these big companies, further displacing the less commercialized aspects of the web. These are like parasitic fish attached to the underbelly of the leviathan, their existence only made possible by the sheer size and dominance of these colossal cornerstones of the modern Internet.

You can be mad all day about the BonziBuddy business model of these big companies, but that's not going to change much other than needlessly raising your blood pressure. It's much more effective to make deliberate choices about which technologies you use, based on what value you find in them. Google is amazing for locating online storefronts and information about local businesses. So use it for that.

An option to the humanly impossible quest of exposing yourself to the Internet without the distortion of an intermediate search engine or link aggregator, is to construct a series of alternative navigational aides that promote different virtues, and emphasize the content we find interesting, and filter out the content we already see more than enough of to have our fill.

Most search engines that position themselves as alternatives to Google aren't. Sure they may not be quite as invasive, but they're really all just doing the same thing Google does, just slightly worse. The bigger problem with Google is its lack of interesting search results, and very little effort seems to be made toward solving that most pressing problem.

I don't even think you need a big budget to attack this problem. On the contrary, I think the scope of the work usually grows to fit your budget. I think the only way to know if you can make it to the stars is to audaciously reach for them yourself.

## The Work Begins - Winter 2021

To demonstrate this point, I set out to construct a search engine that seeks out the web I want to browse. The crazy, creative web. My aim was to "compete" with the scope of Google c.a. year 2000. They had a billion URL index. I felt I could do the same. I could do it better. I didn't need a data center, or tens of thousands of employees. I didn't need planetscale computing or whatever the latest buzzword is. I could be scrappier, I could build this myself, I could run it on small hardware in my living room.

At first I felt my arms were indeed long enough to slap God, so I figured the ultimate insult to big tech would be to run this on a Raspberry Pi 4-cluster. I figured most software nowadays is slow because it's too complicated, and the numbers sort of indicated this might actually be possible. After all, a billion 64 bit integers is just short of 8 Gb. You could allow 100b worth of data per URL and still fit within a 1 Tb hard drive. That seemed on the verge of doable, and that was all I felt necesssary to proceed!

Unfortunately, that was a bit too audacious. I had to rein in my ambitions to make it work. The hardware was simply too limited. It worked for a few million URLs, but not much beyond. Index look-ups were slow. Back to the drawing board. I built a server out of consumer hardware. It needed to sit in my living room, and I didn't want a noisy tower of jet engines bellowing heat into my apartment, so unfortunately no 42U server rack filled to brim with supermicros; but a Node 804 with packing a Ryzen 3900X, 128 Gb RAM, and a 4 drive IronWolf ZFS. It does make some noise when its crawling, but it's absolutely nothing compared to commercial gear.

Several months of work later and the search engine works pretty well. It's severely lacking in bells and whistles, but it works better than I had ever imagined it would when I set out, and shows exactly what I wanted to demonstrate: The Internet, as you remember it, it hasn't gone anywhere. What has changed is the lenses you view it through. You simply can't find it on Google anymore because it isn't always "mobile first", it doesn't always use HTTPS, it doesn't always have adsense ads. But it's still mostly there.

I initially called the search engine "edge crawler", since I envisioned it would seek out a sort of silver lining of quality sites within the web, which I guess it does to an extent, but its scope is much broader than I had originally intended, so I'm rebranding it as the "astrolabe" in keeping with the somewhat space:y theme of gemini. An astrolabe is an antique and medieval tool with large applications in (medieval) astronomy, astrology, timekeeping and navigation. [1]


### Check it out:

* [Gemini Link](gemini://marginalia.nu/search?gemini%20protocol)
* [HTTPS Link](https://search.marginalia.nu/)

Note that I will have to take this down to rebuild the index sometimes. Don't expect complete uptime. I'm gonna need even more hardware before that is gonna happen. But there's always wiby.me to keep you company when its down.

Right now it only crawls HTTP and HTTPS, but I am working on adding some form of gemini support as well down the line. Exactly what form that takes will have to be decided, as the feature not only needs to be useful, but non-disruptive--both for the search engine and the gemini space.

## A sample of what is to come

It's been an interesting technical challenge and I've had to reinvent a few wheels to make it work. I plan on doing more detailed write-ups on some of the considerations when designing a search engine like this. Since I don't plan on commercializing this, I will divulge a lot of information about the algorithms I'm using.

These are the obstacles any search engine will have to face:

### Crawling Economy

I don't mean in the sense of money, but rather in what you are getting out of your crawling.

* Link quality assessment - PageRank and the like was amazing twenty-five years ago, but maybe there are options? Maybe the biggest enemy of PageRank is the hegemony of PageRank-like algorithms.
* Even without PageRank, link farms are a significant problem, and they are often constructed to be effectively endless. It's common to see random subdomains matching DNS wildcards linking to random URLs that randomly generate links to more of the same.
* Balancing discovery with indexing. Ideally, you want to discover new domains faster than your indexer runs dry, but not so fast that the indexer can't ever keep up. You also don't want to spend an exorbitant amount of time indexing every page on for example wikipedia, that's not useful. Wikipedia is well known and has its own search feature.

### Indexing and Presentation

* Existing database solutions do not scale well to indexes that range in the hundreds of millions of entries and hundreds of gigabytes of data. O(n) means hours of work. A poor choice of O(log n) can mean minutes. Every query algorithm needs constant access time or O(log n) on an aggressively reduced working set. A search engine needs to be fast, it should produce near instantaneous results.
* Snippet generation is very hard. HTML is not a particularly standardized format, and reliably producing a page summary that is relevant is not something I've solved yet. Not for a lack of trying. Nobody is using <meta name="description"> anymore, barely even old websites.
* Tokenization. What constitutes a word? Is "R2D2" a word? Is "243a7b722df240d7a886c69b0758e57d" a word? If I search for "bears", should I expect to match the word "bear"? Tweaking this rules can have a very large effect on the size of the dictionary used by the index, and indeed the index itself.

Stay tuned, and you may learn what is in the "filthTable", how to memory map 100 Gb of data in a language that hard caps memory maps to 2 Gb, and more.


* [[1] On Astrolabes](https://web.archive.org/web/20070701013844/http://astrolabes.org/astrolab.htm)

