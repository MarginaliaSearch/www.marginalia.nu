+++
title = "The System Upgrade"
date = 2021-07-30
section = "blog"
aliases = ["/log/09-system-upgrade.gmi"]
draft = false
categories = []
tags = ["server"]
+++


Early this winter, when I set up the server that would eventually become marginalia.nu, I did so in order to try out some technology I thought looked cool (proxmox, zfs), and stuff I was exposed to at work and didn't really see the point of so as to see if we could get on better terms with if I had more control (kubernetes).

I based the system on ProxMox, a Linux based virtualization server, which ran a series of virtual machines and containers.

```
ProxMox
┠─ git (ubuntu-server)
┠─ mariadb container
┠─┒ kubernetes (ubuntu-server)
┃ ┠─┒ WMSA (my software)
┃ ┃ ┠─┒ search engine
┃ ┃ ┃ ┠ crawler x 2
┃ ┃ ┃ ┠ crawler orchestrator
┃ ┃ ┃ ┠ index server
┃ ┃ ┃ ┠ assistant server
┃ ┃ ┃ ┠ archive server
┃ ┃ ┃ ┖ search backend
┃ ┃ ┠ rendered page cache
┃ ┃ ┠ static page renderer
┃ ┃ ┠ reddit front-end
┃ ┃ ┠ podcast RSS aggregator
┃ ┃ ┖ SMHI API front-end (swedish weather forecasts)
┃ ┠ elastisearch
┃ ┠ fluentd
┃ ┠ prometheus
┃ ┠ kibana
┃ ┠ grafana
┃ ┠ letsencrypt automation
┃ ┠ nginx server 
┃ ┠ docker repository
┃ ┖ nginx ingress
┖─ Gemini (ubuntu-server)
```

This set-up grew increasingly untenable. Not only was it very difficult to get an overview of what was actually happening, all of these choices have small costs associated with them, of RAM, of space, of CPU; and taken together, I ended up only being able to productively use about half of the ram on my server for what I wanted to. 

The Linux OOM killer kept reaping the search engine index process with 50 out of 128 Gb available memory that was just lost in the layers of abstractions somewhere.

I also have some really neat hardware coming soon; an Optane 900P, which I'm very excited to see what I can do with. It promises low-latency random I/O, which is exactly what I want. This also mandated a rethinking of how this all works in order to make good use of.

Someone famously declared

> “Let's use Kubernetes!” 
> Now you have 8 problems

I do think this is largely a correct analysis. There may be a scale which you'll see more benefits from kubernetes than drawbacks, but that scale is enormous. For smaller operations like mine, certainly anywhere you can count the servers on a few hands, I do think there's a Thoureauian conclusion to draw here: The complexity of working with a solution like kubernetes can only be handled using a tool like kubernetes. In the small domain, such automation creates *more* work, not less. This abstraction is a complication, rather than a simplification, if the concrete isn't already very complicated.

You have logs across dozens of containers, so you can't grep them anymore, so you need elasticsearch and fluentd. But raw elasticsearch is a headache, so you need kibana too. Oh hey, now it's gotten even more complicated. Can't even see when stuff goes down. Better set up monitoring that alerts you. Let's see, prometheus is good. But the GUI is nasty, better get grafana too. 

This is how the snowball rolls. Adding things makes the set-up more complicated, which mandates adding even more things to deal with the complexity, which makes them more complicated, which...

(Prometheus is honestly pretty good, I may install that again; but I think I'll build my own "grafana" with gnuplot)

I'm going to be very blunt and say I don't like kubernetes. Things keep changing and breaking, and when you look for a solution, what you find doesn't work because some variable has changed name again, or a repository has been renamed.

The ecosystem seems very immature. When it works it's not bad, but when it breaks (and boy does it ever break), you're in for a very unpleasant time. I get a sort of Vincent Adultman-vibe from the entire ecosystem. Everyone talks about what is suitable for production, but everything keeps inexplicably breaking, nothing is ever easy to fix; and the solution is always some inexplicable snippet on stackoverflow you're just supposed to blindly run without really understanding.

I also get the feeling dealing with kubernetes that YAML is the new XML. The problem with XML wasn't really the formatting, that's just an inconvenience. The problem was the megabytes worth of configuration in enterprise software. The YAML keeps growing to meet the needs of the growing YAML.

It's not all bad though. I do actually like the idea of microservices. If you do them properly and unix-like while at the same time don't get *too* in love with them so that you can't see how bigger services can be good sometimes too. They're a big reason of why my stuff actually works. I can redeploy parts of the system while others are running. That's amazing because my index server has a boot-up time of up to an hour. 

## The new set-up

Migration took about 12 hours, and that included changes to the software and setting up git hooks for easy deployment. I got rid of proxmox and zfs and went with Debian Buster and ext4 instead. I kicked out kubernetes and half of that ecosystem, and I'm not using any containerization at all.

It's as simple as that. I have one memory in one kernel, one system to keep up to date and patched. I can actually tell you most of what is running on it and what it's doing.

This is it:

```
Debian
┠─ mariadb
┠─┒ WMSA (my software)
┃ ┠─┒ search engine
┃ ┃ ┠ crawler x 2
┃ ┃ ┠ crawler orchestrator
┃ ┃ ┠ index server
┃ ┃ ┠ assistant server
┃ ┃ ┠ archive server
┃ ┃ ┖ search backend
┃ ┠ rendered page cache
┃ ┠ static page renderer
┃ ┠ reddit front-end
┃ ┠ podcast RSS aggregator
┃ ┖ SMHI API front-end (swedish weather forecasts)
┠─ nginx
┠─ git is just a /home directory
┖─ gemini server
```



## External Links

* [Henry David Thoureau - Walden, Economy](https://monadnock.net/thoreau/economy.html)

* [Adam Drake - Command-line Tools can be 235x Faster than your Hadoop Cluster](https://adamdrake.com/command-line-tools-can-be-235x-faster-than-your-hadoop-cluster.html)

* [Itamar Turner-Trauring - “Let’s use Kubernetes!” Now you have 8 problems](https://pythonspeed.com/articles/dont-need-kubernetes/)