+++
title = "A new approach to domain ranking"
date = 2023-02-06
section = "blog"
aliases = ["/log/73-new-approach-to-ranking.gmi"]
draft = false
categories = []
+++


This is a very brief post announcing a fascinating discovery.

It appears to be possible to use the cosine similarity approach powering explore2.marginalia.nu as a substitute for the link graph in an eigenvector-based ranking algorithm (i.e. PageRank).

The original PageRank algorithm can be conceptualized as a simulation of where a random visitor would end up if they randomly clicked links on websites. With this model in mind, the modification replaces the link-clicking with using explore2 for navigation.

The performance of PageRank has been deteriorating for decades and it's to a point where it barely is applicable for domain ranking anymore in part due to changes in how websites link to each other, but also a battery of well documented techniques for manipulating the algorithm in order to gain an unfair advantage. You may get decent results at the very top especially with personalized pagerank, but you don't have to scroll particularly far down in the ranking to find spam earning a conspicuously high ranking using a vanilla pagerank approach. 

This new approach seems remarkably resistant to existing pagerank manipulation techniques. Given a preference-vector, it stays "on topic" remarkably well. 

* [Explore Sample Data](https://www.marginalia.nu/domains/)

## See Also

* [/log/69-creepy-website-similarity.gmi](/log/69-creepy-website-similarity.gmi)
* [/log/20-dot-com-link-farms.gmi](/log/20-dot-com-link-farms.gmi)
* [/log/04-link-farms.gmi](/log/04-link-farms.gmi)