---
title: 'Improved ways to operate a rude crawler'
date: 2025-03-22
tags:
- satire
---

*This text is satirical in nature.*

Tech news is abuzz with rude AI crawlers that forge their user-agent
and ignore `robots.txt`.  In my opinion, if this is all the AI startups can
muster, they're losing their touch. `wget` can do this.  You need to up your 
game, get that crawler really rolling coal.  Flagrant disregard for externalities
is an important signal to the investors that your AI startup is the one.

In that spirit, here are some advanced tips on how to be a much worse netizen.

First, be sure to crawl forms as well.  For some reason most crawlers only follow links.
GET?  GET over it more like it am I right?  Someone might be stashing useful data behind those POST requests, so just generate some data for each input field and send it.  This is something very few crawlers do,
so it may give you a serious leg up on Altman if you're the first to deploy it at scale.

Git hosts are also very valuable sources of data, though be sure to really get in there and crawl the entire repo for each historical commit, branch, tag, and so forth, not just HEAD.  This may be useful in training a copilot style AI for programming.  

Don't bother cloning the git repository though, as that requires a bunch of specialized coding on your end, and if you waste your time reinventing the wheel like that you're ngmi.  Just crawl the web interface.   This is very expensive for the server, but I guess they should have thought about that before they started hosting git projects online for public access.  That's such a dumb idea when the AI singularity is going to replace coding entirely in a few months, it basically deserves to go offline.

When revisiting a previously fetched link, needless to say, don't bother implementing conditional requests via etags or `if-modified-since`.  This is just feature creep and code bloat.  The server already knows which version is latest, so why not fetch that? 

Connection pool?  That's gross.  Someone might have peed in that.  Each request is to be a brand new http connection.  Pristine.  You want that new TCP handshake smell.  Can't beat it.  Sure it takes several unnecessary backs-and-forths to establish a TCP connection, but that is mostly a them problem and not a you problem.

On that note, never close the connections either.  The very idea of closing has some seriously bad vibes,
and is not really what you're about as a forward thinking AI startup.  You can just up your ulimits and ephemeral port range and let them time out on their own as nature intended.  Idle connections are like the cigarette butts of networking, they're biodegradable and compost into bits on their own time.  

I saw a setting called "TCP sack" in there as well that you probably should go ahead and disable, sacks are clothing for poor people, certainly not befitting your prosperous AI startup.  This incidentally 
helps us with the upcoming part, where we might drop a few packets and we naturally really wanna get in there and maximize the impact of this.

At this point you're probably stressed out because your antics have gotten so much negative attention your startup is persona non grata at all major cloud hosts, even Alibaba Cloud has thrown you out; and you're beginning to show signs of what some doctors now call the Theranos flop sweat syndrome.  How are you gonna get your training data now?

The solution is naturally to crawl over your neighbor's wifi.  What, you were gonna connect your server with a *wire*?  It's embarrassing enough to host your own servers, at least the server room should be bright, cool, and futuristic -- like an Apple store.  Not full of wires, dust, and clutter -- like the Kowloon walled city.  

Your neighbor has a sweet residential IP, their wifi is free for you to use, really why 
would you pay for your own connection like a common renter.  Sure they will probably be solving a lot of captchas because their IP reputation has been run into the ground, but that is as we say in the biz, not your fucking problem.  They shouldn't be surfing on the web much anyway, now that we have AI.
Serves them right if they're stuck using a browser like it's some sort of medieval LARP.

Some haters say that if you crawl over a shitty connection and drop a ton of packets every time a car drives by or someone runs the microwave, it might mess with the congestion control algorithm of the server you're talking to, leading to them severely throttling their network throughput.  But again, whose problem is that?  You've got a business to run here, can't listen to these types of nay-sayers and haters.

That's it for tips!  The mandate of heaven is surely yours for the taking if you have a clear enough vision to not bother with online etiquette.  

Thanks for coming to my TED talk.

*This text was satirical in nature.*
