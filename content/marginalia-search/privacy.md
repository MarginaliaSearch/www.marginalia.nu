+++
title = "Privacy Considerations"
date = 2022-09-22
section = "marginalia-search"
aliases = ["/projects/edge/privacy.gmi"]
draft = false
categories = ["docs", "outdated"]
+++


This privacy policy is in effect on search.marginalia.nu.

```
Javascript:             Minimal
Cookies:                No
Local Storage:          No
Tracking Pixels:        No
Social Media Buttons:   No
Third Party Requests:   No
CDN                     Yes (sadly)
Access Logs:            Yes
Log Retention:          Up to 24h
```

No information about which links are clicked is gathered, and it is not possible to historically correlate IP address to search terms, and anonymized internal identifiers are designed not to be stable over time. 

Overall I try to respect privacy as much as possible while still allowing for things like rate-limiting and bug fixing. There is no tracking and unnecessary logging of IP addresses is reduced to a bare minimum. 

Due to a prolonged and aggressive botnet attack I've had to put the server behind a CDN, which means I cannot guarantee perfect anonymity as I do not have insight into what the CDN provider is doing.

Also, with sufficient time and a large IT forensics budget, someone could probably work out who you are and what you have searched for. I have however taken measures to make that as time consuming and expensive as possible, while at the same retaining some ability to diagnose problems with the set up and infrastructure.

Nginx access logging >is< enabled, but old logs are not archived, but rather shredded and purged every 24 hours.

Internal server logs are retained for a longer time period, but IP addresses are anonymized into a 32 bit hash with a random 96 bit salt that rotates on irregular intervals between 5 and 15 minutes.  This is necessary for rate limiting. 

Don't hesitate to reach out if you have questions or concerns.