+++
title = "Local Backlinks"
date = 2021-07-26
section = "blog"
aliases = ["/log/07-local-backlinks.gmi"]
draft = false
categories = []
tags = ["web-design"]
+++


Maintaining links is difficult. My gemini server doesn't have a lot of pages, but already maintaining links between relevant pages is growing more tedious by the page. It's going to become untenable soon.

In part inspired by Antenna, I had the idea of extracting local backlinks, and automatically appending them to the pages that are linked. That way all local links are effectively bidirectional. If new a new post links to an old post, the old post automatically links to the new post. Old pages will thus over time accumulate more links to new pages without manual maintenance.

Extracting this information was a relatively easy scripting job, the output ends up in two easily parsable text files, one with links and one with page titles.

These can then be read by the server and used to create the links dynamically, as well as used to lint existing links and highlight dead ones. This does require a modicum of discipline when writing the gemini markup, as it expects all local links to start with the pattern "=> /", but that is also something that can be checked automatically.

I've written before about the over-linking problem on Wikipedia, that is something I'm careful about not recreating here as the backlinks would further amplify the problem.

An unexpected emergent feature is that automatic back-linking allows for the creation of topical ad-hoc indicies. Merely creating an empty file and referring to it in pages will populate it with links to those pages. Is this useful? I don't know yet, but I will experiment and see if it brings any value. I do think it may help reduce the urge to recreate such topical indices within the posts themselves, and thus to mitigate the risk for over-linking.

## The Code

* [Link data extraction script (just some slapdash bash)](/code/generate-metadata.sh)
* [Server plugin](/code/src/main/java/nu/marginalia/gemini/plugins/StaticPagePlugin.java)
* [/links.txt](/links.txt)
* [/titles.txt](/titles.txt)

## Referenced Pages

* [On The Linkpocalypse](/log/00-linkpocalypse.gmi)

## Referenced Websites

* [Antenna](gemini://warmedal.se/~antenna/)

