+++
title = "The Grand Code Restructuring"
date = 2023-03-17
section = "blog"
aliases = ["/log/75-grand-restructuring.gmi"]
draft = false
categories = []
tags = ["search-engine", "nlnet"]
+++


In general I don't like to fuss over code, but this is exactly what I've been doing in preparation of the NLnet funded work.  I've spent the last month restructuring Marginalia's code base. It's not completely done, but I've made great headway.

Things got the way they got because in general for experimental solo-development projects, I think it makes sense to be fairly tolerant of technical debt. 

Since refactoring is something that is extremely difficult to break up into parallel tracks or do in small iterations, the cost of refactoring is effectively multiplied by the number of people that could be working on the code. 

It's a bit like Amdahl's Law applied to project management. When leaning into this, it allows smaller solo projects to be be extremely nimble compared to larger projects.  Refactoring is very cheap when you're working alone because there is no resource contention.  This may seem a weird notion if you're coming from working mostly on large projects where any technical debt is nearly irreversible, but that's mostly a problem of large scale software development.

I think just as having a too low standard of code quality is a serious problem for a large project, having a too high standard of code is a bit of a mistake for a smaller one, especially in the early experimental stages.  The trick is to find what's appropriate and gradually raise the bar given the lifecycle of the project.  

It's time to raise the bar.  It has been for a while.

Coming up with a sensible structure for a project like this isn't entirely trivial. This is probably the biggest reason it's taken this long to get around to it. 

I considered the problem from several angles and concluded that there are two solutions to this, what I've done so far (which is to put everything in one big-ass module), or to modularize the hell out of it. Basically depth vs breadth. There is no middle ground. Since what I've been doing has been causing issues, there wasn't much choice.

I can't overstate how large and heterogeneous the search engine problem domain is. There aren't many aspects of computer science that aren't at least in some way connected. Many times it's necessary to implement algorithms specifically for the search engine because off-the-shelf stuff doesn't perform fast enough.  It also consists of multiple web services and batch processes. 

In pulling things apart, there's a risk in doing it too aimlessly. 

Decoupling, while it's a panacea against some forms of complexity, can introduce a form of complexity in its own, where while the code you're looking at is very easy to read, it's difficult to follow how it integrates. It's easy to add layers of abstraction that sort of just delegate, but don't actually provide anything other than obfuscation. As an aside, this seems a particularly common problem among freshly converted Clean Code-enthusiasts. 

To avoid this sort of aimless disconnectedness, I tried to systematize the modules and come up with rules with how they are permitted to depend on each other. The first order of break-down is taxonomical. The family of module depends on how it's used, what it does.

Libraries: A library is independent of the search engine domain. It solves a single problem. Maybe it's a B-Tree implementation, a locality sensitive hash algorithm. Whatever. It does not know what an URL is, or a document. It's more primitive than that.  

These could hypothetically be broken off and shipped separately, or just yoinked from the codebase and used elsewhere.  I decided that these libraries should be co-licensed under MIT to facilitate that, the rest of the search engine is and will be AGPL.

Features: A feature is essentially a domain-specific library. It solves some specific problem. Maybe extracting keywords from a document, or parsing a search query. Features exist to separate conceptually isolated logic. It may only depend on libraries and models.

Models: A module package contains domain-specific data representations. 

APIs: A module package contains domain-specific interface between processes.

Process: A process is a batch job that reads files and performs some task. It may depend on libraries, features and models. It may not explicitly depend on a service or another process.

Service: A service offers a web service interface. It may depend on libraries, features and models and APIs. It may not explicitly depend on a process or another service.

Coaxing the code through this taxonomical system, and further breaking it into services and processes, the module tree looks as follows. Hold onto your hat:

```
api/index-api
api/assistant-api
api/search-api

common/service
common/config
common/service-client
common/renderer
common/service-discovery
common/model
common/process

processes/experimental
processes/converting-process
processes/loading-process
processes/crawling-process

process-models/crawling-model
process-models/converting-model

services-core/search-service
services-core/assistant-service
services-core/index-service

services-satellite/dating-service
services-satellite/explorer-service
services-satellite/api-service

features-search/screenshots
features-search/query-parser
features-search/result-ranking
features-search/random-websites

features-index/index-journal
features-index/domain-ranking
features-index/lexicon
features-index/index-reverse
features-index/index-query
features-index/index-forward

features-convert/adblock
features-convert/pubdate
features-convert/topic-detection
features-convert/keyword-extraction
features-convert/summary-extraction

features-crawl/link-parser
features-crawl/crawl-blocklist

libraries/array
libraries/btree
libraries/braille-block-punch-cards
libraries/big-string
libraries/random-write-funnel
libraries/language-processing
libraries/term-frequency-dict
libraries/easy-lsh
libraries/guarded-regex
libraries/next-prime

tools/term-frequency-extractor
tools/crawl-job-extractor
```


That's a lot of modules. 

Granted, one or two of the libraries are on the `is-odd` side of things, but I think that's fine if it solves the problem of unhealthy interdependence between services and processes. 

I've also made it a rule to not have any like 'misc' modules with just a bunch of unrelated utilities piled in. I think that's an anti-pattern. 

While infinitely easier to navigate than the old git repo, things would still be lacking if this was it.  I figured "poke-around-ability" is a great virtue in code in general, especially open source projects.  That is, something like the ability to quickly navigate to a specific part of the functionality, or just something interesting.

To aid in this, I set up a system of readme.md's that describe each module, points out central classes, and links to related modules or a code sample. Almost like a wiki.

Since broken links is nearly inevitable here, I wrote a quick python script that lints the readmes, warns if a module lacks one, and complains if a link is dead.

As mentioned, this has been going on for a while, and I've taken the time to do some other work within the context of the new repository structure to evaluate the structure and ensure it's not a pain in the ass to work with. 

It's good. I like it.

Not only has isolating pieces of logic into features and libraries made testing them much easier, I've actually found and fixed a large number of bugs because of it, and made tangible improvements to the search result selection algorithm because it's become so much easier to access these parts. 

It's also much clearer when a piece of code isn't all too well tested, because the module will quite simply lack tests.  Some of the features that are known to be a bit janky are also much more exposed and easier to poke and prod at and eventually do something about.

Overall it's been a very healthy thing for the code base. Many of those classes that sort of just fill you with a sinking feeling when you think about changing them, those dragons have mostly been driven to extinction.

Also, holy heck! The compile speed! Breaking the code into modules has made incremental compilation possible on a very granular level. 

The dependency graph also makes it possible to prove which tests need to be run for a given change. If a module doesn't depend on another module at least transitively, the tests within simply can not test that other module.

I'm far more inclined to actually run tests if the entire build takes seven seconds than two full minutes. 

It's also been a good opportunity to look over the developer experience. This still needs work, but the project now ships with docker-compose files that means you can run a local development instance with relatively little friction. It sets up easily, it runs easily, starts and builds quickly.  

Feels good!

## Check It Out

The next step is as mentioned to migrate Marginalia's code off git.marginalia.nu to some git other host, to be decided. For now, the new and old versions can be compared below: 

* [After](https://github.com/MarginaliaSearch/MarginaliaSearch/)

* [Before](https://github.com/MarginaliaSearch/MarginaliaSearch/tree/old-master)

## See Also
