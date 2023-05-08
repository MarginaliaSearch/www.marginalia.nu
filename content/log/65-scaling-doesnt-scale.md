+++
title = "Scaling doesn't scale"
date = 2022-10-25
section = "blog"
aliases = ["/log/65-scaling-doesnt-scale.gmi"]
draft = false
categories = []
+++


By which I mean there are deeply problematic assumptions in the very notion of scaling: Scaling changes the rules, and scaling problems exist in both directions. If what you are doing effortlessly scales up, it almost always means it's egregiously sub-optimal given your present needs. 

These assertions are all very abstract. I'll illustrate with several examples, to try and build an intuition for scaling. You most likely already know what I'm saying is true, but you may need reminding that this is how it works. 

Let's look at nature first.

Put a fly on a body of water, and it will stand on the water. Put a horse on a body of water, and assuming the water is deep enough it will sink to its neck and begin to swim ashore. The fly can walk on the ceiling, the horse can not. Horses can't even walk on vertical surfaces. Neither can cats, dogs, humans, really anything bigger than a small lizard. 

Why? Because if you make something bigger, its weight grows more quickly than its surface area. Things like surface tension, tensile strength scale with area, while weight scales with volume. 

If you are tasked with towing a heavy truck that has broken down somewhere, odds are you will pick a thick rope of modest length before you choose the extremely long string laying next to it. If you pick the string, odds are you will double it several times to increase its cross sectional area at the expense of its length. It is only increasing its cross section that makes it stronger, not its length.

While the examples are from physics, the phenomenon is more fundamental than that. It affects nearly everything. For example, it also affects social relations. 

Consider a group of friends.

* Alice and Bob are in a room; there is 1 social relation in the room. Alice knows Bob.

* Eve enters the room; there are 3 social relations in the room. Alice knows Bob, Bob knows Eve, Eve knows Alice.

* Steve comes along; there are now 6 social relations in the room. (AB, AE, AS, BE, BS, ES). 

* Finally James kramers into the room; there are 10 social relations in the room. (AB, AE, AS, AJ, BE, BS, BJ, ES, EJ, SJ)

If you double the number of members of a social setting, you roughly quadruple number of potential interpersonal relations.  In practice, it's even worse because relationships may involve more than two actors. Bob may be jealous of James and Alice who are in a romantic relationship and holy crap is Eve secretly sleeping with James too! Alice is going to be so mad at James and Eve and thankful to Bob. Steve will scratch his head at the soap opera plot among the other four. 

The formula for the number of 2-person relationships is n x (n-1)/2, or n choose 2. Which brings us to combinatorics and probabilities.

Let's say you found a great deal on extremely unreliable hardware online, and now have a warehouse full of computers that only give the correct response 50% of the time. 

You want to make use of these computers. You decide to set up a cluster to reduce the error rate, use three computers that will use a consensus algorithm to vote on the response. 

With three nodes, the probability of at least a single failure is 87.5%, at least double failure is 50%, and triple failure is 12.5%. 

Wait adding computers seems to have made no difference! The odds of a double error or more is the same as using a single computer! 

What if we use 5 computers? The probability of seeing at least a single failure is 97.5%, at least double failure is 81.2%, triple is 50%, quadruple is 18.7%, quintuple failure is 3.1%. Three is a majority, but the probability of failure is still 50%.

It turns out if your error rate is greater than or equal to 50%, then no matter how many computers you add into the voting pool, it just doesn't improve the situation at all. In this scenario, scaling does nothing. 

If you think about it, it's not that strange. A 50% failure rate is a pretty pathological case, but it does fly in the face of the notion that redundancy improves fault tolerance. It usually does but often not as much as you would think. 

On a single machine, RAID and error correcting RAM is typically not necessary because the probability of failure is extremely low. In a data center, you are a fool if you're not doing both. The probability of a single drive failing among tens of thousands is staggering. You're replacing them daily. ECC is a must, because cosmic rays flipping bits is a real problem on this scale.

A bigger cluster also has far realistic probabilities of otherwise nearly impossible multiple simultaneous faults, creating a need for yet bigger clusters to compensate. 

You may be tempted to think that because in a data center you require double redundancy, RAID-1, and ECC ram; that your dinky little single-server operation needs it as well. That this is somehow the serious way of running a professional server. 

The reality is that if you go that route, you're more than likely paying 10-15 times more for a solution to a problem that is indeed a huge headache for a data center but virtually unheard of on a smaller scale. 

This absolutely goes for software architecture and development methodology as well. A very common mistake software companies make is in their eagerness to grow emulating the methodology of a much bigger company. 

Google is doing this! We should do this too! Netflix is doing that. We should do that too!

Most likely, no, you shouldn't. Netflix has problems that are Netflix-sized. If you aren't Netflix-sized, then you have smaller problems, with smaller solutions. 

You may object that these small-scale solutions don't scale up, but the point of this whole essay is that while indeed they don't, scaling problems exist in both directions. Google's solutions don't scale down. If you copy their homework, you're disastrously hobbling yourself the time where you could be running circles around such lumbering giants.

It's not only OK to be small, it's advantageous.

You can do incredible magical things if actually lean into it and make use of the fact that you play by completely different rules than the big guys. You can walk on water, they can not.