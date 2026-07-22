---
date: 2026-07-22
title: 'Unranked, systemd, crawls'
tags:
- search-engine
---


There's been some changes to Marginalia Search:

* Migrated to systemd from docker
* New unranked query endpoint
* Wide domains got their own index for faster crawls

In brief, this has removed a lot of operational headaches,
reduced expensive queries leaving more computational power for the rest,
and cut crawl times in half.

Let's tackle them in some order.

---

## We have docker at home

The system has been migrated off docker compose, and onto bare systemd in production.
This has been successful, and solved a number of issues.

There are a few constraints that demand a non-standard deployment
for Marginalia.

**NUMA (non-uniform memory architecture).**

The production server has two CPUs, each with their own RAM bank,
and while they can reach over into each other's memory, this comes at a cost.  
In many scenarios this isn't a big deal, but for indexes and databases, 
generally bottlenecked by RAM bandwidth,  this is far from ideal.

**Process lifecycles.**  

A search engine is anything but stateless, 
some processes are fairly heavy and run for weeks, 
some services are very slow to start, 
some services need to restart relatively often.  

This all but demands that the search engine is cut up into different pieces.  
Not necessarily *micro*services, but at least services.  

**IP addresses.**

The crawler (and crawler-adjacent processes) run off about a dozen public IP addresses, 
from the same host.  This is done via ipvlan using network namespaces.  

Linux has many advanced capabilities for giving processes their own virtual network stack, 
which can be wired together with virtual switches and virtual patch cables.
There are to my knowledge no tools for managing this I would consider *good*,
it's all either too low level, or abstracting away key functionality,
or suffering from multiple sources of truths leading to jank when they inevitably differ. 

---

Docker *can* deal with all of these constraints, but at the expense of considerable jank.

Docker's networking model in particular, while it supports ipvlan, doesn't map onto it particularly well,
if you have a finite subnet you pretty much have to have spare free IPs to be able to reliably restart services.
It further doesn't let you set firewall rules for the ipvlan interface, which means that anything you put there 
better not bind on the public IP, or its ass is going to be hanging out in full view.  This is in no way a limitation of ipvlans, but purely a docker problem.

This is made worse by the fact that there is inadequate tooling for letting the processes in the container 
know which network interface is public, so you have to kinda guess based on dowsing rods, RFC 1918, and looking at tea leaves.
This is no way to live.

There is no magic in docker, it's just cgroups and namespaces all the way down, and you can fully replicate what it's doing yourself, if you really want to torment yourself using syscalls or shellscripts, or if you want a middle ground using systemd.  

If docker's problem is that there is a mismatch between the docker model of the system and the system itself, 
systemd represents a more raw approach, where a lot more of the configuration is in your hands,
while still offering many capabilities you'd want for a more serious deployment, 
such as health checks, automatic restarts that can be configured.

Setting up a million `.service`:s is pretty tedious, but drop-ins help.  There isn't a ton to say here, other than after some fiddling, it works very well, and feels a lot more stable than docker ever did.  Cutting JIB out of builds means builds now take 2-3 seconds for the most part.  

Deployments are faster, there's less jank in service discovery because "containers" retain the same internal and external IP,
the whole operation feels considerably less floaty.  Good upgrade.


There are many opinions about systemd, and I think for most desktop-type systems, it's incredibly overengineered and kind of a pain to work with.  Though for something like this, its design is well motivated, and it really shines.  

---

## Unranked Queries

The index now allows unranked query execution!

The query execution pipeline used in the search engine is fairly computationally expensive,
and does things that aren't strictly necessary in many queries.  

If you're for example just looking for backlinks, a pure intersection of the terms 'site:foo.com links:bar.com' is enough,
there's nothing to rank anything there, but things working the way they did, threads were allocated to ranking none the less, term positions were attempted to be retrieved, all a bunch of done that needed not to be done.

So I added a path for unranked queries that just do dumb term intersections and a bare minimum of anything else. 

The bonus of this is that with some fiddling and the construction of a cursor that can map to multiple index partitions, unlike the ranked path, unranked queries can be exhaustively retrieved with minimal additional work. 

Keeping track of the position across multiple partitions to allow exhaustive retrieval took some thinking, 
but I designed a cursor that looks like this, that can be passed to the clients:

```
28mbshfptkj.6ijoop7xty.43nivb3bn1.817ucldxy2x.90.12ria2fmp7a.32cydk0dei2t.73wrhi4igjr.53lb1o4iof7
```

Each period-delimited part starts with a single character mapping to an index partition, and then a string of alphanumerical values that's a base 36-encoded document id, the document id to resume from on that partition.  It's short enough to pass on a query string or along an API query, which is really all that matters.

Implementing this allows up to half of the query load to go to the new endpoint, though many of these queries are driven by bots and scrapers traversing the /site viewer so the exact percentage varies quite significantly.  

The execution time of the new unranked queries usually sits in the ~5ms range, which is at least an order of magnitude below a full query.  A big part of the win is that the unranked queries are single threaded, which frees up many threads from the execution pool to do more meaningful work.

---

## Faster crawls

The crawler's run time has been creeping up for as long as it's been creeping and crawling.  Lately each partition has been taking almost two weeks to finish, and with 8 main index partitions, that's nearly four months to do a full crawl!  This is a bit long, results get plenty stale in that interval.  

The cause of this is a bit unexpected.

The main reason why the crawlers take so long to run is that subdomains are pareto distributed,
and crawler politeness demands we don't hammer websites on the same top domain simultaneously.

A handful of websites (especially substack) are fairly strict on [429](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/429):ing you if you hit them too frequently, 
but even for the rest, it's better to behave well and keep being allowed to visit, 
than to burn the IP being greedy and lose the ability to index them altogether.

This makes for one heck of a bottleneck.  The main crawl finishes in just a few days really, 
and then there's over a week of trickling through substack, medium, wordpress, github.io, neocities.org, etc.

Few puzzles are hard enough that they don't have a clever solution however, 
and the solution I arrived at was to add a new crawler partition, 
to migrate over all these wide domains to this partition, 
and then do a time-based crawl on this domain, 
where the wide crawler crawl however many websites it can in a week, 
then calls it a day to allow the updates to be indexed.

This has worked well.  Now the main crawler finishes in like five days instead of two weeks with little bottlenecking, and the wide partition crawler does its thing in parallel to the main crawler.

---

I don't know what to put here, so I'll leave you with homework instead as this is my blog and I can end my posts in whatever non-sequiteur fashion I like.

Can AI accelerationism a be framed as a secular [millenarian](https://encyclopedia.marginalia.nu/article/Millenarianism) movement?  Is Ken MacLeod correct in that the singularity is just a way of selling the idea of rapture to nerds?  Please publish an essay somewhere arguing for or against this framing.
