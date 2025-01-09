---
title: 'Notes on docker networking with multiple public IPs'
date: 2025-01-09
norss: true
---

The seach engine has had a range of IP addreses for a while, and to be honest, I simply hadn't gotten around to making use of them, and been crawling and serving traffic all from the same IP address.

My scenario is I have a bunch of services that want to be able to talk to each other in private, but some of them should have external IP addresses and be able to reach the outside world. 

I'm putting together these notes as how to do this didn't feel immediately obvious, and I had to piece together the solution from many different sources and forum posts.  

What you want in this scenario is to set up is an ipvlan l3s network for external communication, and an l3 network for internal communication, and a bridge network for host->container access.  

Macvlan, as well as ipvlan l2 and l3 and variants, all have the unfortunate property that they can't be firewalled from the host, which means for a distributed system where you want to dial out from various IP addresses as well as have private connectivity between containers, all your internal ports will be public on the internet, which unless you have to have a separate external firewall on the network, you'll end up with your ass hanging out of the window.

## Solution

In practice, this is the configuration I arrived at.

Nework for crawlers and the like to dial out.   

The 'aux-address="host=ip"' part is key, as it prevents the ipvlan driver form binding to the host part and messing everything up.

```
docker network create -d ipvlan \
  --subnet=193.183.0.160/28 \
  --ip-range=193.183.0.160/28 \
  --gateway=193.183.0.161 \
  --aux-address="host=193.183.0.162" \
  -o parent=enp65s0f0 \
  -o ipvlan_mode=l3s external
```

Here 'enp65s0f0' is the device name for the host's public network interface, your eth0 of yore.


Next, a network for internal traffic, all containers need
this to be able to talk to eachother:

```
docker network create -d ipvlan internal
```

Finally, a network for host access, anything binding ports that should be accessible from the host system needs this:

```
docker network create hostaccess
```

At this point I also needed to add iptables rules.  This isn't documented anywhere, as I understand it (or possibly misunderstand it?), docker should do this automatically, but it didn't work for me.

```
-A POSTROUTING -s 193.183.0.160/28 -j MASQUERADE
-A FORWARD -i enp65s0f0 -o eth0 -j ACCEPT
-A FORWARD -o enp65s0f0 -i eth0 -j ACCEPT
```

(This also fucked with my UFW rules, so I ended up having to migrate them over to iptables too.)

With all of this set up, it works. Containers can dial out, public internet can't dial in.  


### What about bare metal?

All of this is from within docker containers, but if you really get your hands dirty with networking tools, you can translate the configurations to barebones equivalents.  Docker is in the end just a wrapper for some of the [newer linux syscalls](https://man7.org/linux/man-pages/man2/clone.2.html) after all.

I'll leave [a link to some linux documentation](https://www.kernel.org/doc/Documentation/networking/ipvlan.txt) you'll probably [find helpful](https://docs.kernel.org/networking/ipvlan.html) if that is what you came for.

