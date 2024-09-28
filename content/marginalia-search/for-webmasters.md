+++
title = "For Webmasters"
date = 2022-10-28
section = "marginalia-search"
aliases = ["/projects/edge/for-webmasters.gmi"]
draft = false
categories = ["docs", "outdated"]
+++


This search engine is a small non-profit operation, and I don't want it to be cause any inconvenience. 

If it is indeed being a nuisance, please let me know! Send an email to <kontakt@marginalia.nu> and I'll do my best to fix it as soon as possible. 

Telling me lets me fix whatever problem there is much faster, and if you are experiencing problems, then so are probably others as well. 

# Crawler Fingerprint

```
User-Agent: search.marginalia.nu
IP address: 81.170.128.21, 193.183.0.162-174
```

# robots.txt

The search engine respects robots.txt, and looks for the user-agent "search.marginalia.nu" in specific, as well as general directives. Note that changes to robots.txt may not take effect immediately. 

You can also send me an email if something is indexed that you want me to remove. 

# Why isn't my page indexed?

Odds are it just hasn't been discovered yet. The search engine has a pretty small index, and makes no pretenses of being complete.  You can expedite the discovery by [submitting it here](https://github.com/MarginaliaSearch/submit-site-to-marginalia-search).

Otherwise, there are several factors that cause domains to receive extra scrutiny, because they share traits with link farms.  This mostly means .xyz and .icu domains or IPs in Russia, China, Hong Kong, or Taiwan.  This definitely affects innocent websites, but the sad fact is that easily 90% of the link farms are hosted in these countries, and on these TLDs.

For similar reasons, if you are hosted on a large VPS provider that does little internal policing, especially Alibaba or Psychz; you may not get crawled.  The crawler sometimes gets blocked by CDNs like Fastly and CloudFlare, so it may or may not index them depending on whether the bot is being throttled.

Searching for "site:www.yourdomain.tld" will provide you with an analysis. If the search engine is aware of the domain, there should be a button for slating it for crawling.   If you get nothing, then odds are the search engine has no knowledge about the domain yet.

# A Call To Action

Please link to other websites you like! Keep a bookmark list, a blog roll, whatever. You don't have to try to trap your visitor by only linking to your own stuff. 

Links make the Internet more interesting and fun to explore for humans, gives it a community feeling, and it both helps my search engine discover websites and helps it understand which websites are interesting. 

* [A longer write-up](/log/19-website-discoverability-crisis.gmi)

* [My bookmarks](/links/bookmarks.gmi)
