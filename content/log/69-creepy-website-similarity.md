+++
title = "Creepy Website Similarity"
date = 2022-12-26
section = "blog"
aliases = ["/log/69-creepy-website-similarity.gmi"]
draft = false
categories = []
tags = ["search-engine", "programming"]
+++


This is a write-up about an experiment from a few months ago, in how to find websites that are similar to each other. Website similarity is useful for many things, including discovering new websites to crawl, as well as suggesting similar websites in the Marginalia Search random exploration mode.

* [A link to a slapdash interface for exploring the experimental data.](https://explore2.marginalia.nu/)

The approach chosen was to use the link graph look for websites that are linked to from the same websites. This turned out to work remarkably well. 

There are some alternative feature spaces that might have been used, such as TF-IDF data. Using incident links turned out to be surprisingly powerful, almost to an uncanny degree as it's able to find similarities even among websites that Marginalia doesn't index.

As a whole the feature shares a lot of similarity with how you would construct a recommendation algorithm of the type "other shoppers also bought", and in doing so also exposes how creepy they can be. You can't build a recommendation engine without building a tool for profiling. It's largely the same thing.

If you for example point the website explorer to the fringes of politics, it will map that web-space with terrifying accuracy.

* [qanon.pub's neighbors](https://explore2.marginalia.nu/search?domain=qanon.pub)

Note again how few of those websites are actually indexed by Marginalia. Only those websites with 'MS' links are! The rest are inferred from the data. On the one hand it's fascinating and cool, on the other it's deeply troubling: If I can create such a map on PC in my living room, imagine what might be accomplished with a datacenter.

You might think "Well what's the problem? QAnon deserves all the scrutiny, give them nowhere to hide!". Except this sort of tool could concievably work just as well as well for mapping democracy advocates in Hong Kong, Putin-critics in Russia, gay people in Uganda, and so forth.

## Implementation details

In practice, cosine similarity is used to compare the similarity between websites. This is a statistical method perhaps most commonly used in machine learning, but it has other uses as well. 

Cosine similarity is calculated by taking the inner product of two vectors and dividing by their norms

```
       a x b
  p = --------- 
      |a| |b|
```

As you might remember from linear algebra, this is a measure of how much two vectors "pull in the same direction". The cosine similarity of two identical vectors is unity, and for orthogonal vectors it is zero.

This data has extremely high dimensionality, the vector space consists of nearly 10 million domains, so most "standard" tools like numpy/scipy will not load the data without serious massaging. That juice doesn't appear to be worth the squeeze when it's just as easy to roll what you need on your own (which you'd probably need to do regardless to get it into those tools, Random Reprojection or some such). 

Since the vectors in questions are just bitmaps, either a website has a link or it does not, the vector product can be simplified to a logical AND operation. The first stab at the problem was to use RoaringBitmaps.

```
    double cosineSimilarity(RoaringBitmap a, RoaringBitmap b) {
        double andCardinality = RoaringBitmap.andCardinality(a, b);
        andCardinality /= Math.sqrt(a.getCardinality());
        andCardinality /= Math.sqrt(b.getCardinality());
        return andCardinality;
    }

```

This works but it's just a bit too slow to be practical. Sacrificing some memory for speed turns out to be necessary. Roaring Bitmaps are memory efficient, but a general purpose library. It's easy to create a drop-in replacement that implements only andCardinality() and getCardinality() in a way that caters to the specifics of the data. 

A simple 64 bit bloom filter makes it possible to short-circuit a lot of the calculations since many vectors are small and trivially don't overlap. The vector data is stored in sorted lists. Comparing sorted lists is very cache friendly and fast, while using relatively little memory. Storing a dense matrix would require RAM on the order of hundreds of terabytes so that's no good.

The actual code rewritten for brevity, as a sketch the and-cardinality calculation looks like this, and performs about 5-20x faster than RoaringBitmaps for this specfic use case:

```

    int andCardinality(AndCardIntSet a, AndCardIntSet b) {

        if ((a.hash & b.hash) == 0) {
            return 0;
        }

        int i = 0, j = 0;
        int card = 0;

        do {
            int diff = a.backingList.getQuick(i) - b.backingList.getQuick(j);

            if (diff < 0) i++;
            else if (diff > 0) j++;
            else {
                i++;
                j++;
                card++;
            }
        } while (i < a.getCardinality() && j < b.getCardinality());

        return card;
        
     }

```

This calculates similarities between websites at a rate where it's feasible to pre-calculate the similarities between all known websites within a couple of days. It's on the cusp of being viable to offer ad-hoc calculations, but not quite without being a denial of service-hazard. 

To do this in real time, the search space could be reduced using some form of locality-sensitive hash scheme, although for a proof of concept this performs well enough on its own. 

## Closing thoughts

This has been online for a while and I've been debating whether to do this write-up. To be honest this is probably the creepiest piece of software I've built.  

At the same time, I can't imagine I'm the first to conceive of doing this. To repeat, you almost can't build a suggestions engine without this type of side-effect, and recommendations are *everywhere* these days. They are on Spotify, Youtube, Facebook, Reddit, Twitter, Amazon, Netflix, Google, even small web shops have them. 

In that light, it's better to make the discovery public and highlight its potential so that it might serve as an example of how and why these recommendation algorithms are profoundly creepy. 

