---
title: 'Marginalia: 3 Years'
date: '2024-02-25'
tags: 
- 'search-engine'
- 'nlnet'
---

It's been three years since the inception of Marginalia Search, then
a dinky experiment to find where the heck the cool Internet has gone, 
now my full time job. 

While there's always things that can be improved, it's fair to say
the search engine has never worked as well as it does right now. 

A great number of milestones have been reached, perhaps biggest 
of all the search engine has moved out of my living room and into 
a proper enterprise server.

An overarching theme for the year has been cleaning up the code 
base and streamlining the application, not only to keep the
operational workload manageable, but to make the application and
codebase more accessible to other people, both operators and 
developers.  It's been a lot of work, but it's beginning to pay 
off.  

It feels distant, but the search engine used to require days-long outages when switching
indexes.  This is gone.  Since recently, it's also capable of zero
downtime upgrades.  So much of the operational side used to be weeks-long
manual processes, now you press a button in a GUI instead. 

Something which had an outsized impact was adding support for 
anchor text keywords.  It's made an incredible difference in 
the search engine's ability to find relevant results.  It wasn't 
immediately apparant when the change was made, beacuse it initially 
wasn't very well integrated, but as this new relevance signal settled 
in, that was a real wow moment.

It's also been something like eight months since this became my full
time occupation, thanks to the generous people at nlnet.
This has been a bit of a trip in its own regard. The hardest part 
about this has probably been not working *too* much, I've been trying to 
take at least one day off per week, and sometimes succeeding!  I know I'm
leaps and bounds smarter when I'm well rested, so actually resting sometimes
should theoretically be in line with getting stuff done.  It's just so fun 
though...  

The quest to reach 1B indexed documents is slowly ongoing.  It's proving
a bit harder than anticipated, not because the software can't handle it, 
but because the signal to noise ratio of the web isn't very good; a huge
reason why the search engine works relatively well is because of what it 
doesn't index.  That said, the index has gone from 50-100M a year ago, 
to 220M last crawl, and likely 290-300M when the next crawl round is finished
based on the growth of the two partitions that have already finished. 

Next on the chopping block is query parsing and execution.  There's a great
deal of room for improvement in this area.  I'm currently engaged in a bit 
of mise en place to clean up the affected code before the real work begins.

That said, the grand leaps forward in this project has always been experimental, 
so even though things are planned, I think it's fairly certain it's the un-planned 
things that will be the ones to really make a dent.  Like those anchor texts. 

Finally! Thanks [NLnet](https://www.nlnet.nl), thanks [FUTO](https://www.futo.org/), 
thanks Patreons, thanks advocates, and users.  This wouldn't be possible without you.