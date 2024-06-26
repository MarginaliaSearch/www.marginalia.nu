---
title: "One year of solo dev, wrapping up the grant-funded work"
date: '2024-06-18'
tags: 
- 'nlnet'
- 'search-engine' 
---

[A year ago](/log/83_full_time/) I walked out of the office for the last time.  I handed in my corpo laptop, said some good-byes, and since then I have been my own boss.  

This first year has been funded by an <a href="https://nlnet.nl/" rel="external noopener">NLnet</a> grant, which I'm in the midst of wrapping up.  As of now, the work is all done, the final request for payment has been sent.  

There's a similar last-day-of-school levity to both these events.

The grant funded work ends but the search engine development does not end with it; the project is independently funded for a good while longer.  Project runway runs out late 2026 if nothing changes.

This post is an account of the experience, a retrospective of what's been done, and a glimpse toward the future.

<hr>

Working like this is pretty special.  I really don't mind solo development, I never have.  I don't mind having coworkers either, but I think I probably have a higher than average tolerance for not having coworkers.  

The biggest struggle has probably been not working too much.

Even though the plan felt relatively relaxed, the work is ultimately rewarding and *hard to put down*.  

There's this notion of the solo-entrepreneur that works 80 hour weeks out of some misplaced sense of hustle culture.  Personally at least even though I've logged more hours than I probably should have, I don't agree with the description.  Maybe the "grindset" is something external onlookers infer when they see someone working like this...?  Or maybe it's a thing, but not my thing?  I don't know...

It's categorically not a good thing.  I know from experience that you get a lot smarter if you don't work every waking hour of the day, and any project is realistically better off run by a refreshed smart guy than an overworked idiot that hasn't seen daylight for a week.  

I also feel this imperative to put this time to effective use, since it's not just my own time and money I'm wasting if I don't, but that of all the people who have supported the project.  That is, to be clear, a reason to resist the urge to work too much, not an argument for it.

I did eventually get better at prying my ass away from the keyboard toward the end of the year after starting to feel worn. 

<figure>
<img alt="green wall of shame" href="no-days-off-for-good-behavior.png" src="no-days-off-for-good-behavior.png">
<figcaption>Christmas eve, really?</figcaption>
</figure>

It's a juggling act to be your own boss.  There's always other things you could be doing, and you need to simultaneously care about minutiae and the bigger picture, execute the project and tell the world about it, on top of managing life in general.  I could probably do with a bit more structured approach, but at the same time, having too much structure is really stifling for creavitiy.  It's a tricky mixture to get right.  

I feel as though I'm so far off the beaten path here there really isn't much in terms of role models or mentorship to be found, so there's not much option but to find a way to muddle through.

The biggest contrast, the thing to get used to, is that when you're a wagie, you for better or worse can be pretty sure where you will be and what you're going to be doing a few years down the line, and what surprises come are typically in the form of bad things.  Going out on your own like this, I have no idea where I'll be a few years down the line, and surprises are generally good.  You need to operate a bit more on faith than would make sense in a salaried position.

<hr>

If you're accepted for a grant like this, you're tasked with writing a project plan.  In writing this plan 18 months ago, I looked at the problems the search engine was faced with and imagined how they may be improved.  

I picked mostly things that were kind of chores that I felt stood in the way of where I wanted the project to head, these are things that would have been hard to focus on if there was a more performative element, if for example I was immediately dependent on soliciting donations to fund the day-to-day. 

The chosen problems were in broad strokes:

* The search engine was open source in name but nobody could build it and it had no documentation and the code base had a lot historical clutter making it very hard to navigate.  Even though it's unlikely that internet search engine software will ever see mass adoption or a huge number of contributors, it is never the less a key part of the resilience strategy for the project to have some way it can continue to exist if my instance can no longer be maintained.

* The crawler used a really ill-advised data storage format, zstd-compressed json, to keep the crawl data.  

* The system required a completely untenable amount of manual work to operate.  It was designed fairly unix:y, composed of multiple executables with had their own purpose.  The problem was that these needed to be run in a very particular order, SQL statements needed to be manually run between them, and if you got it wrong you lost 2 months of crawl data. 

* The query parsing and understanding was more than a bit rough.  It performed reasonably well, but was written in a way that was extremely difficult to reason about and above all hard to modify.  

Most of these things have been addressed and it's overall gone pretty well.  I've finished nearly to the week a year after the work got started in proper.  This is not so much due to having Hari Seldon-level foresight in planning the project, so much as that I kept inserting other tasks whenever the project seemed ahead of schedule.

I'm happy with how most of the things turned out, even if there's of course always more to do.  

As for things that didn't go well, the query understanding work probably missed the mark the most.  The structural problems with the code have been addressed, and it is an improvement in precision, there's still a fair number of queries the search engine doesn't quite deal with as well as I'd like.  I had hoped to see a larger improvement, but there's reason to think this failure to deliver is because the index needs better term position resolution than the sentence-level information that is presently available.  It would probably have been better to address term position resolution first, although at the time of applying for the grant, the search engine was targeting much smaller hardware and overall this seemed like a riskier change. That's the nature of planning any larger project though, you're always operating on incomplete information.

Assessing where the project is now and looking ahead, there are two major areas I'd like to address.

**The term position resolution is bad:**  As mentioned previously, the index currently uses a bitmask to store keyword position values on a sentence level.  This works well in a surprising number of cases, but certain queries can simply not be handled well.  Word n-grams with named entities make up for some of the shortcomings but a more traditional postings list is probably required to address this situation.  I've already started working on a solution for this, and it's going well, but it's a very large change and will likely not see production until the end of the summer.

**The path toward 1 billion documents is slower than I'd like:** The search engine is at about 300M documents now, and growing the index is slow and tends toward deeper indexing the currently known domains.  The problem of growing  the indexed data needs some re-evaluation.  Every time it grows there's also a fairly large increase in spam porn/hate/spam  results, that currently needs to be manually pruned.  It's also appealing to index e.g. pdf files.

There's a more detailed [roadmap for 2024-2025](https://github.com/MarginaliaSearch/MarginaliaSearch/blob/master/ROADMAP.md) with some additional ideas for changes, though it's very unauthoritative.  One of the things I look forward to after the grant has run its course is at least for a while just winging it for a bit, as that's when I do some of my most inspired work.

Though in the immediate term I'm gonna take some time off, try to, ... we'll see how well I'll manage.  