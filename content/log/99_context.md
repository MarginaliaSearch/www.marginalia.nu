---
title: 'Contexts, Friction and Distractions'
published: '2024-01-30'
tags:
- 'platforms'
- 'moral-philosophy'
---

I get significantly more work done when I unplug my computer from the Internet.  It's not that my productive output drops to zero when I'm plugged in, but more like 70%.

Despite many of the tools that I use requiring a connection, and certainly the Internet containing a wealth of information that might expedite my work, these benefits are drastically outweighed by the wealth of distractions also available.

It's very appealing, when the code is compiling or the docker containers restarting, to sneak open a browser tab with hacker news, or the &Chi; formerly known as Twitter, youtube, or something else to pass those minutes.

This ruins focus, drains energy, and overall just eats a lot of time.  It's easy to find an hour has passed and you haven't really done... anything.  Or an afternoon, heck even a weekend.

Unplugging completely is a drastic action that unfortunately doesn't tend to stick.  Absolutely everything chafes when you unplug.  It's just too appealing to just leave the wire plugged in just this once, realize how much easier life becomes, and then to fall back into old habits.  Attempting to solve smartphone procrastination by switching to a dumb phone has similar properties.  These things increase the friction to do perfectly reasonable everyday tasks, and as a result, push you back into the bad habits you were trying to escape.

Being self-emplyed and working form home also presents the opposite problem.  It's very easy for work to bleed into the time you should be relaxing.  Refreshing dashboards and responding to business emails on the phone while watching a movie, etc.  This is draining, not very productive, and again impacts the quality of work.

Workspaces or full-screen window managers don't really seem to help much either.  The problem here doesn't appear to be *seeing* the distractions.  It's still very easy to context switch, and there's a legitimate use in doing multiple things at the same time sometimes.  Preventing that increases the friction to work.

If the problem is that these "cures" makes the thing you want to do more of harder, while undoing the configuration temptingly lets you slip back into not having to put in as much effort; then maybe there's a better solution.

Maybe the thing that is truly undesirable is context-switching.  If that's the case, maybe suppressing the modes themselves shoudln't be thought of as the cure, but separating them more clearly might do the trick.

In this spirit I've been experimenting a bit with making context-switching chafe more, while keeping the contexts easy to use for their intended purposes.

I set up different user accounts on my computer for different tasks.  One for work, and one for play.  Then I set up two privoxy instances configured for each mode;  a work-privoxy that blocks social media, news-sites and other time-wasters, and a play-privoxy that blocks github, systems dashboards, etc.  The accounts are also configured to not have visibility into each other's home directories.

This has the property that while you can choose to work or play, you can't do both at the same time.  It needs to be a deliberate choice.  If you want to switch from one mode to the other, you need to stop what you are doing, close all applications, and commit to the other mode.

The point isn't to turn into some sort of John Carmack style digital desert father that works around the clock and never has fun, in fact *only* having a work-mode is probably not something that is going to last very long, since you'll be constantly tempted to fall back into the resting state of mixed work.

The point is to drive up the friction to context-switch, while retaining the ease of work and play within the corresponding context:  If you decide to work, you can work effortlessly.  If you decide to play, you can do that too, but not while telling yourself you are working.

After test-driving this for a few days, I think it's working pretty well.  It's definitely much less annoying than unplugging completely.  There's no sense of struggle against the settings.

It would probably be even better to have two separate computers in distinct rooms to mentally drive home the idea, but that isn't really practically doable for me at this point.  Best I could accomplish was to style the two users to look very different.
