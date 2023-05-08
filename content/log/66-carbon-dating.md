+++
title = "Carbon Dating HTML"
date = 2022-10-27
section = "blog"
aliases = ["/log/66-carbon-dating.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


One of the more common feature requests I've gotten for Marginalia Search is the ability to search by date. I've been a bit reluctant because this has the smell of a a surprisingly hard problem. Or rather, a surprisingly large number of easy problems.

The initial hurdle we'll encounter is that among structured data, pubDate in available in RDFa, OpenGraph, JSON+LD, and Microdata.

A few examples:
```
<meta property="datePublished" content="2022-08-24" />
<meta itemprop="datePublished" content="2022-08-24" />
<meta property="article:published_time" content="2022-08-24T14:39:14Z" />
<script type="application/ld+json">
{"datePublished":"2022-08-24T14:39:14Z"}
</script>
```

So far not so that bad. This is at least a case where the web site tells you that here is the pub-date, the exact format of the date may vary, but this is solvable. 

HTML5 also introduces a <time> tag, which is sometimes useful. 

```
<time pubdate="pubdate" datetime="2022-08-24T14:39:14" />
<time itemprop="datePublished" datetime="2022-08-24T14:39:14">August 24 2022</time>
<time datetime="2022-08-24T14:39:14">August 24 2022</time>
```

The last one may or may not be the timestamp we're looking for, but maybe it is in the right ballpark anyway. 

Thus we've taken a first step into the realm of dubious heuristics. Sometimes the URL path contains the year a document was created, typically on the form

```
https://www.example.com/2022/04/why-im-so-great/
```

Of course /four digits/ may just be some numbers as well. It's not possible to be quite sure, but usually it's right. We can clamp the year to [1989,current year+1] and reduce the false positives.

The HTTP header 'last-modified:' (or Last-Modified) may also provide a hint. It may also be the last time the file was copied on disk. Or complete nonsense. It's also probably a RFC-1123 date.

Alright, this will provide a date for about a quarter of the websites. More than likely, none of these things work. Well to really grasp at straws, we can look for bylines and similar in the DOM using common class names. 

It's not really computationally feasible to look at *all* the elements, but these classes usually contain publish or change-dates:

```
.entry-meta
.byline
.author
.submitted
.footer-info-lastmod
```

We can also look for text nodes with strings like "Copyright", "Published", "(c)", and so forth. 

Although copyright notices aren't great. You often see stuff like "(c) Bob Smith 1997-2017". How to narrow it down? Well we can just split the difference and say 2007, and we would probably be closer to the truth than if we went with the 1997 or 2017, but we can actually guess better than that. 

By looking at the HTML standard, we can coarsely make a guess about roughly which decade a website belongs from. New HTML3 is very rare in 2022, HTML5 is impossible in 1995. HTML4 and XHTML is typically indicative of 1999-2014.

So from "(c) Bob Smith 1997-2017", and HTML3 we can take the average of 1997 and 2017, which is 2007, and make an educated guess from the HTML standard, say 1997, average those and arrive at 2002 and then clamp it to 1997-2017 and arrive at an educated guess that the website content from 2002. 

In all honestly, I have no good argument why this should work, in fact, averaging averages is rarely a good idea, but in this case it does give very plausible estimates. In general, this is heuristic is mostly necessary when dealing with older web pages, which often don't strictly have a well defined publishing date. 

Finally, in keeping with the 30 year old Internet tradition, my own website flagrantly disregards the part of the HTML5 standard that says <articles> must have a <time pubdate>...  but is correctly dated using Last-Modified.

