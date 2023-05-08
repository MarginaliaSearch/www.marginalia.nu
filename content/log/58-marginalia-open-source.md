+++
title = "marginalia.nu goes open source"
date = 2022-05-27
section = "blog"
aliases = ["/log/58-marginalia-open-source.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


After a bit of soul searching with regards to the future of the website, I've decided to open source the code for marginalia.nu, all of its services, including the search engine, encyclopedia, memex, etc.

A motivating factor is the search engine has sort of grown to a scale where it's becoming increasingly difficult to productively work on as a personal solo project. It needs more structure. What's kept me from open sourcing it so far has also been the need for more structure. The needs of the marginalia project, and the needs of an open source project have effectively aligned. 

So fuck it. Let's make Marginalia Search an open source search engine.

I don't know how much traction this will get in terms of contributions, but as search is like a fractal of fun and interesting problems to be tackled it's almost a bit cruel to keep it all to myself. 

There's some effort in documenting the project and cleaning up the build process needed before this can get going in earnest, but that will be an ongoing task for quite some while. This work was needed regardless, and if nothing else this serves as a good vehicle for introducing some process into the development of this project and getting around to slaying some of those ancient dragons (this is necessary at this point regardless).

## Sources and Hosting

I feel GitHub has taken an incredibly toxic turn with its emphasis on social features, and in general dislike the notion of renting space on the Internet, therefore I'm hosting the sources on a gitea instance.

* [https://git.marginalia.nu/marginalia/marginalia.nu](https://git.marginalia.nu/marginalia/marginalia.nu)

As of right now the code is very as-is. There is still some work to get it to a point where it's even possible to run on another machine.

I'm currently looking for hosting for a large term frequency data file that is necessary for several of the search engine's core functions. I really don't have the bandwidth to serve it myself. It's only a couple of hundred megabytes so it'll probably be solvable somehow. 

# Q&A

## What if the SEO people learn all the secrets?

They're probably going to figure them out anyway. If Google teaches us anything, it's that attempting to hide what you are doing from the SEO industry flat out doesn't work. 

What shields Marginalia from SEO spam isn't security through obscurity, but that it places demands on websites that are mutually contradictory to Google's demands. As long as Marginalia Search is smaller than Google, Marginalia is safe.

## I don't like Java

I know a lot of people break out in eczema when exposed to this language. Rest assured it's not enterprisey Java, and between the JVM's ability to interoperate with other languages (including Python and Scheme), and the fact that the entire system is based around web services, there's *probably* something that can be done to accommodate for other languages-of-choice.

## What is the license?

It's AGPLv3. 

## I have strong negative opinions on something about the project

If you feel the need to complain about how something doesn't align with your personal philosophical convictions and fails to satisfy your criteria for ideological purity, please write a really long and angry essay about this topic, and send it to <kontakt@marginalia.nu>. 

Don't forget to press caps lock as you begin typing to save your pinky fingers, I wouldn't want to be responsible for nasty RSI.

