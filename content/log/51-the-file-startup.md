+++
title = "The Static File Startup"
date = 2022-03-18
section = "blog"
aliases = ["/log/51-the-file-startup.gmi"]
draft = false
categories = []
tags = ["programming", "satire"]
+++


Note: This is satirical in nature. Slight CW if you are at a point in life where "Office Space" has unveiled itself as a disturbing existential horror movie. This taps into that the same darkness.



A tale of six brave Internet pioneers.

  Senior Business Founder / Senior CEO -- Zach
  Senior Tech Lead / Senior Architect / Senior CTO -- Kevin
  Senior Backend dev
  Senior Frontend dev -- Erin
  Two Senior UX engineers

Deadline: 6 months

# Mission

We're going to disrupt Internet hosting and serve static files in a novel way through a cloud based SaaS. In the MVP it's just "Thus Spake Zarathustra" in the original German and the lyrics to Auld Lang Syne (we found both on archive.org under the public domain). 

We're really stoked to innovate in this space, and think our SaaS-offering will really disrupt how the Internet works.

# Sprint 1

We've decided to store the files in a NoSQL database, as files have a hierarchical nature, and relational databases are from the past. We're all very committed to using modern technology.

We've opted to choose Cassandra as that is the first ad that came up when googling "2022 nosql database". Nobody knows how to use Cassandra, but that will probably work out fine. Most of the team was spending the sprint trying to find tutorials on stackoverflow.

We've gotten started on the REST APIs, it's slow work because everyone has very strong opinions. 

The debate was between

  GET /files/:filename

and

  GET /file/:filename

We went with the second after Kevin threatened to quit. 


We finished the Sprint with a hackathon. 

# Sprint 2

The backend will be implemented in Java 18 and SpringBoot and WebFlux, it will load configuration from a yaml file and then pass along requests to cassandra. Our backend guy had a nervous breakdown so Kevin, Erin and the UX team are piecing this together from Baeldung samples. So far it works fairly well, although we're struggling getting WebFlux to perform as well as we'd hoped. We're not sure why.

The frontend will be a SPA that reads the URL-fragment and sends a request to the backend and fetches the document. We found a javascript library that sends asynchronous requests and loops until they return (asynchronous is good because it's faster), and another that replaces the current page contents with the string you provide, and finally one that checks whether a string is empty, although that last one has a lot of dependencies so it takes like 10 minutes to build... 

# Sprint 3

We felt that javascript was kind of from the past, so we're going all in on Kevin's hackathon project of concept that transpiles a functional dialect of Algol 68 into webassembly (except Kevin was adamant all the variable names must be emojis, and when pressed why he just sent an aubergine and left Slack). It's been a lot of work getting it to work but it feels stable now.

We also got a tote bag with the company logo, pretty sweet.

# Sprint 4

The UX team is really not happy with the document just loading when you visit, they want to add a transition animation and smooth scrolling when you load the page, we also really need analytics and tracking to see how far the visitor scrolls and when they select something. To get all this to work we need to render the text onto a canvas with WebGL. We apparently also urgently need third party fonts but the CEO says they are illegal in Europe so now we need a consent popover for European IPs before they can view the file. 

# Sprint 5

It's turned the Algolmoji transpiler was really buggy, and Kevin has quit, so most of us have been attempting to fix it. Whenever you use emoji skin color modifiers the code crashes. It got out on twitter and there is a real shit-storm about it from two really angry accounts. VC are really nervous and threatening to pull our funding. This is a big problem and all hands are on deck and they've been crunching hard to address the problem.

It also turns out that Nietzsche was a German. We're really nervous the angry twitter accounts will discover this, but we've invested too much to change the 50% of the MVP now.

# Sprint 6

Most of the code works now, although there is a memory leak in the Algolmoji interpreter so the browser crashes the tab if you scroll too far into Also Sprach Zarathustra. We're trying to figure out why. We suspect it may be a bug in the operating system. We're not convinced any window can scroll that far, it's a very long text file, like far longer than anything else, by our calculations the graphics card can't have enough vram to store that many pixels at once. Hopefully it's not a showstopper.

It also turns out we can't use GET for the REST API, we need to do a weird thing and use POST because the path may contain "../" and then for some reason the app server starts resolving files in the system directory. Yikes, that was a close call. This is not idiomatic REST but we're too far in to find a good solution.

# Sprint 8

This sprint has been devoted to getting the DevOps flow going, we've set up a process for building docker images of the front-end and back-end, with git hooks that deploy directly to kubernetes. Most of us have only written YAML these two weeks, including the founders. How can there be this much YAML?

At the same time, we've gotten far! Grafana, Kibana, Elasticsearch, Prometheus, Letsencrypt, it's all set up and working. We're very proud. We're also scaling automatically, which may be necessary, as the back-end code seems very slow and keeps crashing for some reason. 

Serving static files isn't easy but thankfully we have all these great open source solutions to help. Can't even imagine the work we'd have to do keeping this system running manually.

The feeling is good. We're confident we're gonna make it big. 

# Sprint 9

We've finally managed to set up Cassandra! It's been really stressful, but we finally found a tutorial that worked after three months of googling! PHEW! The entire MVP almost works, although the character encodings are all wrong. Hopefully that doesn't matter too much. 

# Sprint 10

Another hackathon.

Erin was experimenting with old fashioned web technology and discovered you can just serve files with a regular web server, like straight from a directory, and these web servers are like free and super easy to set up. She demonstrated our entire start-up can be replaced with a raspberry pi. Over two months of work. Millions of dollars of start-up swag down the drain? We've had a meeting. Do we gamble that nobody knows and push ahead, we can't compete with this if it's common knowledge. Do we pivot to hosting images instead? The founders were reassuring we could still make it big. Monday morning we discovered Zach's took the remaining money and ran. We don't know what to do. 

VC is threatening to sue. 

Help.



# Responses

* [gemini://perplexing.space/2022/re-the-static-file-startup.gmi](gemini://perplexing.space/2022/re-the-static-file-startup.gmi)