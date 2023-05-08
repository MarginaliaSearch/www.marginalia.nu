+++
title = "Discovery and Design Considerations"
date = 2022-01-18
section = "blog"
aliases = ["/log/44-discovery-and-design.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


It's been a productive several weeks. I've got the feature pulling updates from RSS working, as mentioned earlier. 

I've spent the last weeks designing the search engine's web design, and did the MEMEX too for good measure. 

It needed to be done as the blog theme that previously made the foundation for the design off had several problems, including loading a bunch of unnecessary fonts, and not using the screen space of desktop browsers well at all. 

Contrary to what one might think, I don't hate colors or non-brutalist design, I just dislike how its often abused to the detriment of the visitor.

An important consideration is having a clean interface that doesn't unnecessarily drag attention away from what the visitor is attemping to focus on. It's been previously mentioned the disastrously noisy web design of Wikipedia. The search engine has gotten a bit noisier than it was before, but hopefully it's not gotten too noisy. 

Furthermore, I've overhauled the random exploration mode. 

Discovery is one of the main missions of this project, and it's been a vision for quite some time to offer some alternative means of literally browsing the internet, perusing its domains like you would flipping through a magazine. 

On the one hand, you can get a random selection from about 10,000 domains in the personal website sphere, but it's also possible to manually direct the search and show sites adjacent to a particular domain, using a combination of straight link-information and Personalized PageRank.

The mechanics of extracting random interesting links have been around for a while, but the design was more than a little bit rough. 

An idea came to my mind that perhaps it would work better with some visual element to offer a taste of the flavor of the websites. It's easy enough to slap together a script that does that: Take one headless chromium, sprinkle a pinch of python, couple of weeks later you have one low-res screenshot per domain across half a million or so domains. (It's still running, by the way)

* [https://search.marginalia.nu/explore/random](https://search.marginalia.nu/explore/random)

You can either just refresh the "random"-page to get new domains, or click the "Similar Domains"-links to get results adjacent to that particular domain. It's pretty entertaining.

The problem is just how to get visitors to discover this feature, since I specifically don't want distrating elements that draw attention to themselves. This is doubly tricky because of the strict no-cookie policy of search.marginalia.nu. Many sites would probably have something like a one-time dismissable window, or effect, or animation. That is simply not doable here. 

The single remaining option is to improve the signal to noise ratio that the links don't vanish in the noise.

## See Also

* [/log/00-linkpocalypse.gmi](/log/00-linkpocalypse.gmi)
* [/log/03-writing-for-reading.gmi](/log/03-writing-for-reading.gmi)
* [/log/27-getting-with-the-times.gmi](/log/27-getting-with-the-times.gmi)

