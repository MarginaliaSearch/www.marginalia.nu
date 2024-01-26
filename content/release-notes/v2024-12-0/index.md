---
title: "Release Notes v2024.01.0"
published: "2024-01-24"
tags:
- "search engine"
- "nlnet"
---

This is a major new release of the search engine software, corresponding to nearly four months of changes.  In these months, the state of the code hasn't been stable enough for a new release, but it's now been brought to a stable point.

Release Highlights:

* The installation procedure has been cleaned up.
* It's now possible to run the search engine in a white label/bare-bones mode, without any of the Marginalia Search branding or logic.
* The Marginalia Search web interface has been overhauled.  The site-info page has especially been given a large upgrade.
* The search engine can use anchor texts to supplement keywords.
* The search engine can use multiple index shards.
* The operations GUI has been overhauled.
* An operations manual has been written.
* The crawler can now resume crawls in process due to intermediate WARCs.
* The search engine can import several formats without external pre-processing.
* The Academia filter has been improved
* The Recipe filter has been improved
* The system now penalizes documents that have obvious hallmarks of [being written by ChatGPT](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/e53bb70bef7dc833c88f689d6fbf052f45c9f3cb) in its quality assessment.

Other technical changes:

* Several bugfixes in the ranking algorithm has improved search result precision
* Domain link graph have moved out of the database, improving processing time
* The system can be configured to automatically perform db migrations
* Ranking algorithm improvements

Known Limitations:

* Service discovery is currently a bit limited, making it only possible to run the system within docker (or similar) at this point, as host names and ports are not configurable.  This is not intended to be a permanent state of affairs.
* The Marginalia Search website has lost its dark mode.
* There might be an off-heap resource leak in the crawler.  It's primarily a problem with very long crawl runs.

## Barebones Install

The system can be configured to run in a barebones mode, which only starts the minimal number of services necessary to serve search queries.  A HTTP/JSON interface is provided to enable the search engine to act as a search backend.

There isn't really any good "off the shelf" ways of running your own internet search engine.  Marginalia Barebones wants to address that.  Out of the box it offers both a traditional crawling-based workflow, as well as sideloading worflows for various formats, such as WARC or just directory trees, if you'd rather crawl with `wget`.

As this is this is a first time it's been possible to run the search engine in this fashion, it's at this stage not very configurable, and a lot of the opinionated takes of the Marginalia search engine are hard coded in.  These are intended to be relaxed and made more configurable in upcoming releases.

The barebones install mode is made possible in part due to an overhauled installation procedure.  A new install script has been written offering a basic install wizard.  Configuration has also been broken out into mostly being a single `properties` file.

A video demoing the install and basic operations of this is available here:

<figure>
  <a href="https://www.youtube.com/watch?v=PNwMkenQQ24"><img src="/release-notes/v2024-12-0/demo.png"></a>
  <figcaption>Screenshot of the <a href="https://www.youtube.com/watch?v=PNwMkenQQ24">demo video</a></figcaption>
</figure>


* [PR 53](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/53)
* [PR 73](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/73)
* [a0f28a7f](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/a0f28a7f9b5aaa85a38e9c46f6c30c929e6ed940)
* [73499600](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/734996002c13bf22edb77f450ed152232ba10695)
* [7c6e18f7](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/7c6e18f7a77f9dda06ecfb9b82c8156d3b9e5990)
* [c9fb45c8](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/c9fb45c85fe2a0c48abceb84b59a31a95a6c5a3b)
* [4c62065e](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/4c62065e7459675b43d371e4143339cfdcfe1ff8)


## Overhauled Web Interface

The Marginalia Search web interface has been overhauled.  The old card-based design didn't really work out, and has been replaced with something a bit more traditional.  The filters have moved out of a dropdown next to the search query and into a sidebar, making them more visible.

<figure>
  <img src="/release-notes/v2024-12-0/search-view.png">
  <figcaption>Screenshot of the new <a href="https://search.marginalia.nu/search?query=thrice+greatest+hermes&js=default&adtech=default&profile=default&recent=default">search results page</a></figcaption>
</figure>

The site info view has been significantly overhauled, integrating several discovery/exploration features.  Experimental RSS support is added, as well as

<figure>
  <img src="/release-notes/v2024-12-0/site-view.png">
  <figcaption>Screenshot of the new <a href="https://search.marginalia.nu/site/jvns.ca?view=similar">site info page</a></figcaption>
</figure>

The site info view also presents information about the site's IP and ASN, both of which are searchable.  You can also include (or exclude) autonomous systems by name in the search query,  e.g. `as:amazon`.

<figure>
  <img src="/release-notes/v2024-12-0/site-site-link.png">
  <figcaption>Among other features, site crosslinks are <a href="https://search.marginalia.nu/crosstalk/?domains=signal.org,support.signal.org">made explorable</a>.</figcaption>
</figure>

* [PR 61](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/61)
* [PR 67](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/67)

## Anchor Text Support

The search engine can now use anchor texts to supplement the keywords in a document.  This has had a very large positive impact on the search result quality!  An [in-depth write-up](/log/93_atags/) is available going over the details of this change.

Marginalia Search makes its <a href="https://downloads.marginalia.nu/exports/">anchor text data</a> freely available, along with the other data exports.

* [PR 59](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/59)

## Multiple index shard support

The system now has support for multiple backing indices.  This permits a basic distributed set-up, but can also e.g. allow pinning different parts of the index to specific physical disks.  There is a write-up going over the [details of this change](/log/92_multirack_drifting/).

Some of the internal APIs have also been migrated off REST to GRPC.  This is an ongoing process, and several more APIs are slated for migration in future releases.

* [PR 55](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/55)

## New Operations GUI

This concludes the final polishing pass on the operations GUI.  The GUI offers control over all of the operations of the search engine, as well as monitoring and configuration.

<figure>
  <img src="/release-notes/v2024-12-0/crawl_in_progress.png">
  <figcaption>Screenshot of the control GUI, crawler running</figcaption>
</figure>


Most operations are now available via user-friendly guides with inline documentation.

A manual is also available at [https://docs.marginalia.nu/](https://docs.marginalia.nu/), explaining the concepts in depth.

<figure>
  <img src="/release-notes/v2024-12-0/control-gui.png">
  <figcaption>Screenshot of the control GUI, export wizard</figcaption>
</figure>


<details>
<summary>Commits</summary>

* [264e2db5](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/264e2db53939a89a59f875024cd8ff9e56aa5bda)
* [0caef1b3](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/0caef1b307120ee58a8a08a43f713b5a8a291808)
* [de3a350a](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/de3a350afe82829da3e0c1768f6df47a7331b75d)
* [56d832d6](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/56d832d6611206642718a969caea701da5a847a4)
* [98c09726](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/98c09726199da304247731d1fb01a7f4568209e1)
* [c0fb9e17](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/c0fb9e17e8ac8fa2f0bb13e850098881324f78ca)
* [8dea7217](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/8dea7217a611923f7b49d9100152c1b18a127c3f)
* [81eaf79a](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/81eaf79a2531e35d949caa6ccd54c5e34880a8c4)
* [2fefd0e4](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/2fefd0e4e319804c98e242d7fddc3368aeed0528)
* [71e32c57](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/71e32c57d96474bedacc455cd2214d439338b56e)
* [ecd9c352](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/ecd9c35233f324bbbc4654048dfb374546d2a75c)
* [b192373a](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/b192373ae712cdc2f78e071d53a322286fc06a44)
* [f29a9d97](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/f29a9d972d71b25faa926be2ddc7394853aa2743)
* [c0b15427](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/c0b15427fe69295b1c5590712de7c689aea01fff)
* [c41e68aa](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/c41e68aaab381a291df1eb81670a46f41b60698f)
* [19e781b1](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/19e781b104109c1f119f9ce4d8c8a59997ba03e2)
* [67ee6f41](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/67ee6f4126bb6c34466793a92c07dcc40b326d18)
* [175bd310](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/175bd310f5f09069cef100fcfd68a72397a8b816)
* [6271d5d5](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/6271d5d544f480bb07b5b9255958a76d76937417)

</details>

## Crawler Modifications

The crawler can now resume crawls in process due to storing in-progress crawls in the WARC format.  Upon completion of a domain, the WARC is converted to parquet.  The system can be configured to keep the WARCs for archival purposes, but this is not the default behavior as WARC files are very large, even when compressed.

Previously the crawler would restart crawling a domain from scratch if it crashed or was restarted somehow.  Thanks to this change, this is no longer the case.

The crawl data is no longer stored in compresed JSON, as before, but in parquet.  This change is still not 100% complete.  This is due to the needs of data migration.  To avoid data loss, it needs to be done in in multiple phases.

In implementing this, a few inefficiencies in dealing with very large crawl data was discovered in the subsequent processing steps.  A special processing mode was implemented for dealing with extremely large domains.  This runs with a simplified processing logic, but is also largely not bounded by RAM at all.

* [PR 62](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/62)
* [PR 69](https://github.com/MarginaliaSearch/MarginaliaSearch/pull/69)

## Improved Sideloading Support

The previously available sideloading support for stackexchange and wikipedia-data has been polished, and no longer need 3rd party tools to pre-process the data.  It's all done automatically, and is available from an easy guide in the control GUI.

The index nodes have been given upload-directories, to make it easier to figure out where to put the sideload data.  The contents of these directories are visible from the control GUI.

<figure>
<img src=""/release-notes/v2024-12-0/sideload-wizard.png">
<figcaption>Screenshot of one of the new sideloading wizards</figcaption>
</figure>

* [27ffb8fa](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/27ffb8fa8a81f4d740027d3dfd0c10e5b8ee2fdd)
* [40c9d205](https://github.com/MarginaliaSearch/MarginaliaSearch/commit/40c9d2050fcd453f4738116b9801e41804095409)

(also a few others)


## New Search Keywords:

* `as:ASN` -- search result must have an IP belonging to ASN
* `as:asn-name` -- search result must have an AS with an org information containing the string
* `ip:country` -- search result must be geolocated in country
* `special:academia` -- includes only results with a tld like .edu, .ac.uk, .ac.jp, etc.

* `count>10` -- keyword must match at least 10 results on domain (this will likely be removed later)
