+++
title = "The Anatomy of Search Engine Spam"
date = 2022-02-07
section = "blog"
aliases = ["/log/46-anatomy-of-search-engine-spam.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


Black hat SEO is endlessly fascinating phenomenon to study. This post is about some tactics they use to make their sites rank higher. 

The goal of blackhat SEO is to boost the search engine ranking of a page nobody particularly wants to see, usually ePharma, escort services, online casinos, shitcoins, hotel bookings; the bermuda pentagon of shady websites.

The theory behind most modern search engines is that if you get links from a high ranking domain, then your domain gets a higher ranking as well, which increases the traffic. The reality is a little more complicated than that, but this is a sufficient mental model to understand the basic how-to.

## Comment Spam

Creating a bot that spams links in forums, guestbooks, comment fields, wikis is a really old-fashioned method. These links were never intended for humans to click on, but for search engines to register.

In practice, since the rel=nofollow became standard practice, this is not particularly effective anymore as the attribute tells search engines to disregard the link. Some comment spam lingers as a mechanism for controlling botnets, sharing some of the cryptic eeriness of the numbers stations of the cold war.

Source control systems, mailing lists, issue trackers, pull request systems, and so forth are also targets for spam, some of which do not to this date append rel=nofollow to their links to this date.

## Dead Links

An often overlooked side of link rot is that when a site dies, links often linger to the domain. This allows a spammer to simply register that domain, and immediately have search engine clout.

This seems like a fairly low-level problem, probably won't be fixed without changes to DNS or the way HTML addresses resources.

## Hacked Websites

This is another way of piggybacking on a domain's ranking. 

Especially in older websites you can find strange hidden links. They may be hidden from rendering (style="display: none"), or they may be hidden from the human editor (perhaps 400 blank spaces to the right of a line of text). This seems to be manual work. 

## Link Farms, Link Rings

There are websites full of almost nothing but links to similar websites. Not intended for humans, but for search engines. The pages appear dynamically generated with wildcard subdomains, almost invariably on cheap clounds and with cheap tlds. 

Alone this isn't very useful, but combined with some of the other techniques, appears to act as a sort of lens, magnifying the ranking of a target domain.

* [Further Reading](/log/04-link-farms.gmi)

## Wordpress

Among newer websites, there are a lot of hacked wordpress instances, anyone with a web server will see probes for wordpress vulnerabilities several times per hour. What happens when they succeed is often not immediately noticeable, but often hundreds or thousands of pages are added, hidden, full of link spam, taking the same rough shape of the link farms mentioned previously.

* [Further Reading](/log/20-dot-com-link-farms.gmi)

## Questionable Sponsorships

Online casinos almost seem to have marketing as their primary expense, and have been observed sponsoring open source projects in exchange for a link to their domains.

It may of course be hard to reject money, especially when in need, but at the same time, but maybe this practice should be stigmatized more than it is. 

## In Closing

There are no doubt other techniques being used as well, but these appear to be the most common. It's an uphill battle, but knowing is a big part in combating this problem. 

Beyond all else, "rel=nofollow" should be mandatory for all links submitted by users, if nothing else because you become a far less appealing target for spammers.

