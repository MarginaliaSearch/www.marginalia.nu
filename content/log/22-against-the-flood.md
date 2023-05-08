+++
title = "Against the Flood"
date = 2021-09-19
section = "blog"
aliases = ["/log/22-against-the-flood.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


So hacker news apparently discovered my search engine, and really took a liking to the idea. Actually that's a bit of an understatement, the thread has gotten 3.3k points and lingered on the front page for half a week. And I wasn't planning for it to go quite that public yet. It has quietly been online for a while, but it was only very recently it started to feel like it was really coming together. It wasn't perfect, there was still a lot of jankiness and limitations that could have been fixed with more time. The index was half the size it should have been. Someone discovered it and shared it. It took off like a rocket, and I'm still at a loss for words at the reception it's gotten. I have received so many encouraging comments, emails, offers of collaboration, a few have even joined the patreon. I've been working through all the messages and I aim to reply to them all, but it takes time. I'm very grateful for all of this, since I half thought I was alone in this. 

In building this, I had a hunch I was the next TempleOS-guy, quietly building something ambitious the world just wouldn't be able to relate to. Turns out that just the case at all.

But rewinding back a bit to last Thursday when this all began. I looked at a log and noticed I got more searches than usual. It quickly turned into a lot more searches. The logs just kept scrolling at a dizzying rate as I was tailing them. I didn't know then, but the server was getting about 2 search queries per second, a sustained load that lasted most of the night. The server withstood the barrage without going down, without even feeling slow.

To be perfectly clear, my server, and I have just one of them, it's a single computer. It is not a 42U tower like what you see on /r/homelab, but simple consumer hardware. The motherboard is a kinda shitty mATX board, the CPU is a Ryzen 3900X, and it has 128 Gb of RAM but no ECC. Stick a high end GPU in it and it would basically be a gaming PC with a silly amount of RAM and a weird disk configuration. The modest little cube sits quietly humming in my living room next to a UPS I got a few weeks ago because of all the the thunderstorms and outages this summer. 

My home network flows through a cheap router I've had since 2006, 100 mbit, I purchased it when I first moved to my own apartment. I really think this is the craziest part of the whole story. If anything were to just keel over and die at managing tens of HTTP requests per second, it would be that piece IBM-beige antiquity (actually looking at the backside reveals that it was once grayish-white, but sitting in the sun for 15 years does things to plastic).

I had done some performance testing, and knew the search engine ought to hold up to a decent search pressure. But you don't really know if the ship floats until it's in the water, and here it suddenly found itself on an unexpected maiden voyage across a stormy ocean. There's a lot of moving parts in software this complex, and only one of them needs to scale poorly to bring it all down. But apparently not. In fact, due to how memory mapping interacts with disk caching, it searches faster now than it did before.

## How is this even possible?

I'm too well-acquainted with survivorship bias to pretend I know exactly what the secret sauce is. But I can offer some guesses:

* I serve most things that doesn't need to be dynamic as static HTML off nginx. This means that page loads are tiny, in many cases they can be less than 10 KB. I do load some fonts, but they should only load once, and even so the page load is about 100 KB. 
* I don't use cookies except to manage log-ins to MEMEX and my reddit front-end. This means the server doesn't have to keep track of session data for anyone other than myself. I don't have exact figures of how many people visited my server, but if I go on how many searches I got, it's probably around a half a million to a million visits. That's half a million sessions that didn't need to be managed by the webserver. 
* I originally built the search engine targeting a Raspberry PI cluster. It's been quite a while since I migrated off it, but I do think this shaped the original design in a way where it needed to be extremely thrifty in terms of making use of hardware. Overall I think targeting small hardware is a very good practice when designing performant software, as it becomes extremely evident whenever you are doing something that is inefficient.
* Java, for all its warts, boilerplate, and unfashionable enterprise-ness, is pretty good for building reliable web services.


## The Future

I'm still processing all of this. It's extremely encouraging how many people seem to like the idea. The project is in its infancy, and I have many ideas for improvements. There are also things that need to be tested to see if they work. It's probably going to be a pretty bumpy road, but I'm extremely grateful that I have people with me.

Below are the things I'm working toward right now.

### Short term

* There are some pretty arbitrary limitations on the search terms. I do think they can be softened a bit. 
* When you search for something and there are no good results, you currently get seemingly random links instead of an empty page. I'd like to try to see if I can prevent this, as it makes people think the search engine isn't working properly.
* There's a lot of junk in the index due to a few bugs I recently discovered; binary soup, and pages with character encoding errors. These are hard to get rid of, so I need to re-crawl these pages and reconstruct the index. I will probably do this in a few weeks when the public attention has died down a bit, as it means taking it all down for a day, and then having awful search results for a few more days. 
* I want to see if I can, if not automatically perform, at least suggest alternative search queries, pluralization, term re-ordering, etc. NLP is pretty hard though, and there doesn't seem to be good libraries.
* I'm thinking of resurrecting my pi cluster and using it as a a smaller test environment so that I don't break "production" as much now that I have actual users. Should also help with keeping the performance in check.

### Long term

* I may opensource a few of the specialized components used in the search engine. I built them typically because I couldn't find anything available that fit my rather unique requirements.
* I want to crawl gemini space as well as HTTP.
* I want to experiment with using links-descriptions to paint additional search terms on pages. This is  nontrivial from a storage and computation standpoint when operating under my hardware constraints. 

## Pictures

* [My Server](/pics/the_marginaliaplex.png)
* [The Pi-cluster](/pics/raster-test/picluster.png)

## Links

* [HN Thread](https://news.ycombinator.com/item?id=28550764)
* [My Search Engine](https://search.marginalia.nu/)

