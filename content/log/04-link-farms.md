+++
title = "On Link Farms"
date = 2021-07-14
section = "blog"
aliases = ["/log/04-link-farms.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I'm in the midst of rebuilding the index of my search engine to allow for better search results, and I've yet again found need to revisit how I handle link farms. It's an ongoing arms race between search engines and link farmers to adjust (and circumvent) the detection algorithms. Detection and mitigation of link farms is something I've found I need to modify very frequently, as they are constantly evolving to look more like real websites.

In the mean time, I'll share an autopsy of how link farms operate, and some ways I've approached them. It's a strange and shady business that doesn't get talked about a lot. The advertisement industry is shady. The SEO industry is shadier still. This is the shady part of the SEO industry. It's shady cubed, some real cloak-and-dagger stuff.

The point of a link farm is to manipulate the algorithms used by search engines, typically Google, which several degrees simplified rates a website by how much traffic it gets. Link farms can also serve as vectors for scams and malware, since they allow the construction of unpredictable URLs across different domains that point to similar content, that's hard to detect for spam filters and antivirus software.

Their modus operandi seems to be as follows:

* They register one or several domains somewhere, it's usually .xyz because they are cheap
* They buy some cheap cloud computing someplace, very often Alibaba
* They point wildcard records for *.their-domains.xyz to their cloud ingress
* They upload a website that responds to every URL with a bunch of links to random subdomains with random URLs. Occasionally they will be freebooting content off social media like reddit, or from articles or blog posts to make their content look less machine generated, but surprisingly often they'll straight up be lists of keywords and links.
* They buy expiring domain names and put links to the link farm, and also spam them in forums and free wordpress, blogspot, etc.-blogs.

The fact that they are often using the cheapest domain names should indicate that they register a lot of domains. Often they are shilling hotels or travel-related products, there's also a strange cluster that's squatting in domains that once belonged to pages about blues music; and there's finally a large operation that seem to target the east-asian online shopping market.

The age of man will have expired before you're done indexing just one of these effectively endless tangles of domains and hyperlinks so simply powering through is not really an option.

I do have some flagging of domains with large numbers of subdomains, but that's a pretty expensive operation that is only possible to run every 10 minutes, and by the time they're detectable, they've already polluted the index quite a bit. Think links across 10 domains x 500 subdomains x 10000 known URLs; for one link farming operation. So far I've identified nearly ten thousand domains, and I do not think this is exhaustive. This is a last resort measure to catch the ones that get through.

It's much better to weed out the rotten eggs before they enter the machinery, and I've found the far most effective solution to this to apply scorched earth tactics, and indiscriminately exclude entire swathes of addresses from crawling. My index is never going to be a complete one anyway, no search engine does that, so I'll ruthlessly take any measure that increases the quality.

I'm restricting the crawling of subdomains in the new generic TLDs and some ccTLDs. As mentioned earlier, .xyz is especially rife with these sites. I think it's a combination of cheap domain names and weak oversight; I've read that they have been a major source of email spam as well. An unfortunate side effect is that this cuts off a lot of domain hacks. "cr.yp.to" is one site I for example currently will not index despite it having otherwise interesting content.

I'm also IP-blocking sites that don't use the www-subdomain, when they are hosted in Hong Kong, China, Taiwan, India, Russia, Ukraine, or South Africa. It's not the least fair as there are legitimate websites of interests hosted in these countries and domains, but again it's very effective.

Repeatedly I'm met with the disheartening conclusion that we just can't have nice things.

## Appendix: Number of identified link farm domains by TLD

```
xyz    2622 gTLD
com    1776 gTLD
tw     535  ccTLD Taiwan
online 511  gTLD
top    265  gTLD
pw     249  ccTLD Palau
icu    204  gTLD
net    167  gTLD
asia   117  gTLD
site   72   gTLD
```

I would present a breakdown by country, but that would entail making nearly ten thousand DNS queries in rapid succession, and that's just an unnecessary waste of resources.

