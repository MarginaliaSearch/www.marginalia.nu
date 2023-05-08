+++
title = "The Curious Case of the Dot-Com Link Farms"
date = 2021-09-09
section = "blog"
aliases = ["/log/20-dot-com-link-farms.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


I spent some time today weeding out yet more link-farms from my search engine's index. 

Typically what I would do is just block the subnet assigned to the VPS provider they're on, and that does seem to work rather well. The cloud providers that don't police what they host is almost always home to quite a lot of this stuff, so I don't particularly mind scorching some earth in the name of a clean index. 

Today's link farms turned out to be more of a three-pipe problem. They had a pretty predictable address pattern, so it wasn't incredibly difficult to round them all up. Below are two examples out of a million or so URLs I flagged. 

I'm redacting the full addresses. If you click on them, at best you end up at an online casino or a porn site, but there's a pretty decent chance you'll be exposed to malware. 

```
http://█████-███████████████.com/radiorules/wp-content/plugins/book/bacterial-activation-of-type-i-interferons-2014/
http://███████████.com/pdf/download-a-companion-to-renaissance-drama-blackwell-companions-to-literature-and-culture.html
```

It's strange because a large portion of them had .com domains, some had .org and a few even .edu. That's unusual, because these top level domains are expensive and inaccessible. We're also talking about about 20,000 domains. 

My initial response was something like "wow, this operation has deep pockets! That's a quarter of a million dollars per year in registration fees alone." Actually, a bit too deep, the more I thought about the economics of it all, the less it added up. 

One curious aspect is that they didn't quite seem to link very closely to each other. Most link farms do, but the most reliable way of finding these links was to go on URL pattern alone.

Visiting the domain's index page without the full URL usually presented a reasonably innocent-looking website, a few of them were personal sites, some were businesses. Sometimes with signs of poor maintenance, but it seemed to be something someone at some point put actual work into building; not just some low-effort copy-paste facade put up to fool the VPS provider.

That's another clue. Often times link farms will try to look innocent, but I think that's only part of what's going on here.

It slowly dawned upon me

## It's all compromised WordPress deployments!

Yeah, what if these web sites aren't merely fronts, but actual websites made by people and not scripts? Maybe the reason they can afford a quarter of a million dollars in registration fees is because they aren't paying any of it? What if what I'm looking at is in fact 20,000 hacked WordPress deployments?

If you have a web server (or really any TCP port open to the internet), you've probably seen the constant probing. You know, the stuff...

```
2021-09-08T05:54:22+02:00 "GET //site/wp-includes/wlwmanifest.xml HTTP/1.1"
2021-09-08T05:54:23+02:00 "GET //cms/wp-includes/wlwmanifest.xml HTTP/1.1"
2021-09-08T05:54:24+02:00 "GET //sito/wp-includes/wlwmanifest.xml HTTP/1.1"
2021-09-08T09:53:28+02:00 "GET /wp-login.php HTTP/1.1"
2021-09-08T09:53:29+02:00 "GET /wp-login.php HTTP/1.1"
2021-09-08T09:53:30+02:00 "GET /wp-login.php HTTP/1.1"
2021-09-08T10:00:03+02:00 "GET /wp-content/plugins/wp-file-manager/readme.txt HTTP/1.1"
2021-09-08T14:32:41+02:00 "GET /wp/ HTTP/1.1"
2021-09-08T23:52:56+02:00 "GET /wp-content/plugins/wp-file-manager/readme.txt HTTP/1.1"
2021-09-08T23:52:59+02:00 "GET /wp-content/plugins/wp-file-manager/readme.txt HTTP/1.1"
```

I think this is what they do to you if you actually do happen to run an older WordPress installation. 

## Related Links

* [https://search.marginalia.nu/](https://search.marginalia.nu/)
* [/log/04-link-farms.gmi](/log/04-link-farms.gmi)

