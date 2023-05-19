---
title: "Confessions"
date: 2023-05-19
draft: false
tags: [ "programming" ]
---

**I use print debugging all the time**

I know how to use a debugger. I use a debugger sometimes, but most of my debugging is done by print statements that are like

```
A
B
C
.
.
5
D
.
D
,
{true, 30}
.
,
.
,
10
E
```

**I think Clean Code makes some valid points**

I don't think it should be your bible or treated as infallable, having seen the sort of code that came before it, yeah, Uncle Bob got some things right.  He rightfully gets some shit for the stuff that didn't turn out perfectly well as a product of the time, but at the same time, I think we've sort of become blind to how much he got right.

As an aside, I think adjectives like 'clean' and 'pure' makes unthinking zealots of many people. It's very easy to strap a bucket on your head and go conquer the holy land under such a banner.  Replace it with 'moist' or 'brown' and suddenly they'd love to go but they've got some land they've promised to help tilling, and their brother's getting married just this weekend, and their bucket's got a dent in it and maybe it isn't safe to use anymore, but good luck with the crusade, they'll totally go next time do reach out again.

**I use single letter variable names**

```java
long   l;
Object o;
long   L;
```

**My main use of Python is as a calculator app**

It's like `bc` but better.

My median python session:

```shell
$ python3
Python 3.10.6 (main, Mar 10 2023, 10:55:28) [GCC 11.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 1e6/1024**2
0.95367431640625
$
```

**I do most of my data munging in `awk` and `sed`**

... when that doesn't work, I import it into a spreadsheet program.

When I work with JSON, I use `jq`, but I have to look up how to do it every time.

**I think learning new programming languages is in general a waste of time**

Sometimes you gotta but in general I try to avoid it.

Time figuring out the syntax for doing what I want to do in the new programming language is time not spent actually doing what I want to do.

As an educational exercise for inexperienced programmers learning a new language in another paradigm can be useful, but I don't think it's a good use of time for experienced programmers.

**I have spectacularly poor git discipline**

I'll commit four disparate changes in one commit, and the commit message will be "oh you know, ... stuff". I've committed 8000 line diff merges with "will it blend".

**I think memory safety is overstated**

Don't get me wrong, I think memory safety is a good thing, but I also think that the large number of memory-related bugs discovered through analysis tools is mostly due to the fact that memory-related bugs are basically the only category of bugs these tools can reliably discover. 

These tools would never find bugs in the same category as log4shell. 

**I don't know how to do nontrivial stuff in `vim`**

I know about `:wq`, `:w`, `:s`, `/`, and a few basic navigation commands. Beyond that I use the arrow keys.  I've used vim for 15-20 years and I've never bothered to learn how to do anything more advanced.

**I think Waterfall works really well**

All the most successful projects I've been apart of have been defined by large upfront design.  The more agile a project or team has purported to be, the more of a shitshow it has been, sometimes with the specifications being drawn up sevral weeks after the code has been written, sometimes even after it's gone into production.

Of course no true scotsmen would ever run into those problems...

**I think TDD is a methodological cryptid**

I write tests. My code has decent test coverage if it's the sort of code that benefits from that. At the same time I think TDD is a load of crap. I'm still not sure if it's ever actually been done outside of small trivial studies. I don't think it scales to non-trivial applications. In fact, I'm not even sure it exists. I've never seen it done. I've never met someone who has seen it.  Many shops claim to do TDD, but in practice it usualy means "we write unit tests sometimes".

**I re-invent the wheel _all the time_ and it's great**

Yes there are perfectly good libraries out there. Often they do almost what I want, so I need to write some code to adapt them to my needs. Often that code is larger and more complex than the code that would have solved my problem in the first place. 

This also significantly reduces the amount of library churn. I don't have to worry about having to upgrade to a new version that breaks everything, or having to take over maintenance of the library as it's maintainer has lost interest.

I've not only re-invented the wheel once, I've re-invented the same wheel multiple times. I think I've written four different CSV parsers in the last decade. 

**I absolutely butcher 3rd party libs**

When I'm not reinventing the wheel, I'll pull a 3rd party dependency, rip out 80% of the code, optimize the hell of the rest, and document none of it and I usually don't try to backport anything.  It's a real horror show.

**I prefer to figure stuff out on my own**

Yeah I can ask someone for help, but given a choice I'd rather not. I'd rather spend a day figuring out how to do something than spend 15 minutes googling or asking someone who knows how to do it.  It's not that I'm shy or insecure, I just enjoy figuring stuff out and I think the process grants a deeper understanding of the problem space than being handed an answer.

I use the Feynman Algorithm for problem solving and I think it's pretty good.

---

<blockquote> Oh Lord, grant me chastity and temperance, but not yet! </blockquote>
