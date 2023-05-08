+++
title = "Re: To unit test or not to unit test, that is the question"
date = 2021-07-08
section = "blog"
aliases = ["/log/02-re-tests.gmi"]
draft = false
categories = []
tags = ["programming"]
+++

* [gemini://gemini.conman.org/boston/2021/07/07.1](gemini://gemini.conman.org/boston/2021/07/07.1)

I felt the need to add some thoughts tangentially related to this post by Sean Conner.

## Why do we hold unit tests in such high regard?

Enterprise software development (Agile with a TM at the end), and to an increasing degree open source software development has really accepted the Unit Test as personal lord and savior deep within their souls. If it doesn't have coverage, it's bad. If it has coverage, it's good.

(This is an aside, every single company I've worked for the last 12 years has officially said they were doing "Test Driven Development". To this date, I've *never* seen anyone do this. I'm not even sure it exists outside of textbooks and classroom settings. I've seen more compelling evidence of the Loch Ness-monster than TDD. Please let me know if you have any shaky and blurry camcorder footage of this development practice, I'd love to see it ;-)

Anyway, it's an appealing notion that quality can be quantified, but it very rarely is the case. Attempts at quantifying quality usually tends to shift what we mean by quality to no longer be particularly useful. The quantitative and the qualitative realms are in their essence orthogonal, you really can't compute how well a program fits its purpose and if you try, what you are computing is something else.

Let's be systematic:

### Are unit tests sufficient for quality in code?

Since we find low quality code with unit tests all the time, this proposition simply cannot be true.

### Are unit tests necessary for quality in code?

There are other paradigms for code quality, and many examples of code that has never been unit tested yet has high quality. Almost anything written in assembly, for example. There are also other QA paradigms. In-code assertions are great and extremely underutilized today, they make all your testing better.

So for the question of necessity -- no.

### Are unit tests useful for code quality?

This part is entirely subjective. In my experience, they can absolutely be helpful, and I do write a lot of tests for some code, but they can also be useless, even an obstacle to quality; so I don't test all code for the sake of testing it. Tests don't have intrinsic value, but should have a purpose. If you don't know what purpose a test has, you shouldn't write it. That purpose can be to get at some hard to reach code for manual debugging, to exhaust edge cases in a tricky algorithm, to prevent regression during refactoring, any number of things. However if the only purpose of the test is to increase coverage, then it is a harmful test. It adds maintenance cost, it comes at a cognitive penalty, and it took time that could be spent doing something actually useful. As much as testing forces you to break the code apart, breaking the code apart too much just leaves it fragmented and unnecessarily complicated.

In the end, tests are a tool. A bit like mouse traps. If you've covered the entire floor in mouse traps and they've yet to catch a single mouse, then that's just making life harder on yourself. If you put some where you suspect mice, and they sometimes catch a mouse, that's great value for a small investment. 

Prudence is a greatly undervalued virtue in software development. I think true-sounding principles are some of the deadliest things in this business, they completely shut down any sort of evaluative or critical thinking we might otherwise employ. A lot of IT-people claim to be skeptics, but they only seem to employ that skepticism toward things they don't believe, which is a place where it has little use. Principles can seem so true, promise so much, and oftentimes they do, but they also make us completely blind to the fact that sometimes they're superstitions that simply don't hold water.

* Test coverage is great, except when it isn't. 
* Segregating data and I/O is great, except when it isn't. 
* Breaking apart code into smaller pieces is great, except when it isn't. 
* Elaborate commit messages are great, except when they aren't. 
* Mocking is bad, except when it's not.
* All test should have a purpose, except when they shouldn't.
* The principle of not trusting principles is great, except when it isn't.

It's not from a lack of having been there. I've had ample sips of the kool-aid too. Ten years ago I'd read some book by Uncle Bob and it seemed very true, and he did have great points at times. Except when they weren't.

I do think we should at least occasionally approach these sacred doctrines with a degree of flippant irreverence. At least in personal projects where failure is a learning opportunity. It's really the only way to test if and when they are true.

But, que sçay-je?

