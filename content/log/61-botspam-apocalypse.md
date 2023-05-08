+++
title = "Botspam Apocalypse"
date = 2022-08-03
section = "blog"
aliases = ["/log/61-botspam-apocalypse.gmi"]
draft = false
categories = []
+++


Bots are absolutely crippling the Internet ecosystem. 

The "future" in the film Terminator 2 is set in the 2020s. If you apply its predictions to the running of a website, it's honestly very accurate.

Modern bot traffic is virtually indistinguishable from human traffic, and can pummel any self-hosted service into the ground, flood any form with comment spam, and is a chronic headache for almost any small scale web service operator. 

They're a major part in killing off web forums, and a significant wet blanket on any sort of fun internet creativity or experimentation. 

The only ones that can survive the robot apocalypse is large web services. Your reddits, and facebooks, and twitters, and SaaS-comment fields, and discords. They have the economies of scale to develop viable countermeasures, to hire teams of people to work on the problem full time and maybe at least keep up with the ever evolving bots. 

The rest are forced to build web services with no interactivity, or seek shelter behind something like Cloudflare, which discriminates against specific browser configurations and uses IP reputation to selectively filter traffic. 

If Marginalia Search didn't use Cloudflare, it couldn't serve traffic. There has been upwards of 15 queries per second from bots. There is just no way to deal with that sort of traffic, barely even to reject it. The search engine is hosted on residential broadband, it's hosted on a souped up PC. 

I can't afford to operate a datacenter to cater to traffic that isn't even human. This spam traffic is all from botnets with IPs all over the world. Tens, maybe hundreds of thousands of IPs, each with a relatively modest query rates, so rate limiting does all of bupkis.

The only option is to route all search traffic through this sketchy third party service. It sucks in a wider sense because it makes the Internet worse, it drives further centralization of any sort of service that offers communication or interactivity, it turns us all into renters rather than owners of our presence on the web. That is the exact opposite of what we need. 

The other option would be to require a log-in from the users, which besides from being inconvenient, I don't want to know who is using the search engine, but if I don't know who is using the search engine, I can't know who is abusing the search engine. 

Cloudflare is the *lesser* evil in this case. It's not fair, but it at least allows the service to stay open and serve traffic in a way that at least doesn't inconvenience all human visitors all the time.

The API gateway is another stab at this, you get to choose from either a public API with a common rate limit, or revealing your identity with an API key (and sacrificing anonymity).

The other alternatives all suck to the extent of my knowledge, they're either prohibitively convoluted, or web3 cryptocurrency micro-transaction nonsense that while sure it would work, also monetizes every single interaction in a way that is more dystopian than the actual skull-crushing robot apocalypse.

If anyone could go ahead and find a solution to this mess, that would be great, because it's absolutely suffocating the internet, and it's painful to think about all the wonderful little projects that get cancelled or abandoned when faced with the reality of having to deal with such an egregiously hostile digital ecosystem.

## See Also

* [/log/29-botnet-ddos.gmi](/log/29-botnet-ddos.gmi)