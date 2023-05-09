+++
title = "Bot Apologetics"
date = 2021-10-25
section = "blog"
aliases = ["/log/32-bot-apologetics.gmi"]
draft = false
categories = []
tags = ["web-design", "bots"]
+++


There has been a bit of discussion over on Gemini recently regarding poorly behaved bots. I feel I need to add some perspective from the other side; as a bot operator (even though I don't operate Gemini bots).

Writing a web spider is pretty easy on paper. You have your standards, and you can test against your own servers to make sure it behaves before you let it loose.

You probably don't want to pound the server into silicon dust, so you add a crawl delay and parallelize the crawling, and now you have code that's a lot harder to comprehend. This is likely the cause of some weird bot behavior, including mishandling of redirect loops or repeated visits to the same address. Multi-threaded orchestration based on a rapidly mutating data set is difficult to get right (the working set of the spider by necessity changes as it goes). You can iron a lot of this out locally, but some problems won't crop up until you really push the limits with real-world scenarios.

Next, the practical reality of web servers is that standards are more like vague recommendations, and no local testing can prepare your bot for encountering real data, which is at best malformed and sometimes straight up adversarial. 

The only way to exhaustively test a bot is to let it run and see if it seems to do what it does.

The Internet, whether over HTTP or Gemini, is a fractal of unexpected corner cases. In Gemini this is compounded by the fact that a lot of people have written their own servers, in HTTP servers are (usually) somewhat compliant but oh boy is HTML a dumpster fire. 

It's a bit difficult to figure out what you are getting from the server. You can get Content-type as a server header or a HTML header. You can also get charset as a meta tag. HTML is served dozens upon dozens of DTDs.

This one is fun:
```
<!DOCTYPE HTML PUBLIC "-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::extensions to HTML 4.0//EN">
```

Server error handling sometimes causes some problems for a spider:

* You fetch a URL, http://www.example.com/foo
* The page you get in return is a file-not-found error page, but it's served with an OK status code. The error page contains the relative URL bar/
* You index http://www.example.com/foo/bar and get the same error page
* You index http://www.example.com/foo/bar/bar and get the same error page
* You index http://www.example.com/foo/bar/bar/bar and get the same error page

&c

This class of errors shouldn't happen according to the standards, but it crops up relatively often.  It's part of a wider problem with assuming that the Internet is a bunch of static files, when it in practice is often dynamically generated at-visit. This also means you can't just do a simple hash of the pages you've visited to detect a loop like this, since they may include a generation timestamp or some other minor difference.

The wider problem of degenerate URLs is a constant obstacle, and normalization that repairs every case is probably impossible, even a passing solution involves a decent amount of mind-reading and guesswork.

Example: Is "page" in "http://example.com/page" a poorly normalized path ("page/"), or a file with no ending? Both are valid interpretations.

Then there's robots.txt. In this file, you will find things like:

* Every character encoding known to man
* ASCII art
* Emojis
* PHP errors
* MySQL errors
* HTML code
* DIY directives
* Infinite crawl-delays (eff. days/page)
* Robots also get directives from HTML tags, sometimes conflicting with robots.txt.

This was just a short sampler of the types of stuff a bot needs to deal with. 

What I wanted to say is that writing a bot is a lot harder than one would think. It's unfair to assume malice or incompetence when a bot misbehaves: Probably only way you will ever get a reasonably well behaving web spider is to build a somewhat poorly behaving one and go from there.

