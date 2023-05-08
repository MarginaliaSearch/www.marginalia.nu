+++
title = "The Mystery of the Ceaseless Botnet DDoS"
date = 2021-10-10
section = "blog"
aliases = ["/log/29-botnet-ddos.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I've been dealing with a botnet for the last few days, that's been sending junk search queries at an increasingly aggressive rate. They were reasonably easy to flag and block but just kept increasing the rate until that stopped working.

Long story short, my patience ran out and put my website behind cloudflare. I didn't want to have to do this, because it does introduce a literal man in the middle and that kinda undermines the whole point of HTTPS, but I just don't see any way around it. I just can't spend every waking hour playing whac-a-mole with thousands of compromised servers flooding me with 50,000 search requests an hour. That's five-six times more than when I was on the front page of HackerNews, and the attempts only increased.

I don't understand what their game is. 

The thought crossed my mind it could be a racket to get people to sign up for CDNs services, wouldn't be the first time someone selling protective services arranged problems to solve, but it doesn't quite add up. These queries I'm getting...  

The search queries they've been sending are weird.  

I've had, for quite some time, bots spamming queries for casino sites and online pharmacies and what have you, I assume this is to estimate their search ranking and figure out if their SEO is doing its job.
 
A second guess is that it could also be some sort of attempt to manipulate search engines that build predictive models based on  previous search queries for automatic suggestions, but I don't do that so that's not accomplishing anything.

This traffic has only been a harmless smattering of visits, so I've let them do this since they've mostly been wasting their time and not doing me any harm.

These new bots have been searching for... keywords, often related to downloading pirated software or movies. 

At first I thought it was someone looking for content to file DMCA complaints about, but they were really aggressive so I blocked them, and then they started cropping up from other IPs and it became pretty apparent it was a botnet. Addresses were very random and the requests were well orchestrated.

Out of curiosity I pointed my web browser to a few of the IPs, and perhaps unsurprisingly the ones that responded showed login pages for enterprise grade routers and similar hardware. Not hard to imagine how they ended up as part of the bot net.

But for the keywords, it looks eerily a lot like the sort of keyword stuffing you get in compromised wordpress sites. I wonder if the two are related somehow. Maybe it's the same people doing the wordpress compromising that is spamming the search engine?

It's really strange because they can't be looking at the search results at all, they're way overspecified so they are almost never going to return any meaningful responses. I guess that does speak for the suggestion manipulation hypothesis.

I have a lot more questions than I have answers at this point.

