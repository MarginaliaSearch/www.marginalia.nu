+++
title = "Memex Design"
date = 2023-01-13
section = "blog"
aliases = ["/log/71-memex-design.gmi"]
draft = false
categories = []
tags = ["web-design", "memex"]
+++


For clarification, this is discussing no other thing called Memex than memex.marginalia.nu, the website you're probably visiting right now. That, or you're reading this over gemini at marginalia.nu, which is serving the same content over a different protocol.

I wanted to build a cross-protocol static site generator designed in a way that is equally understandable by both humans and machines. This groundedness is an appealing property I really admire about the gemini protocol and gemtext format.  It's something I want to explore if it's possible to extend to software in general.

It will turn out that designing the system from basic principles, it's possible to extract unexpected emergent features from it, including tag-based categorization.

## 1. Filesystem

The memex leans heavily into an explicit filesystem metaphor.

This means that the system is based on entities called documents, and each document has a path that identifies it. This fact is not hidden, but rather front and center. Directory traversal is one of the primary ways to navigate the site. 

Filesystems are neat for organizing information in a way that makes sense both for humans and computers.

On a software level, filesystems are the OG NoSQL database that everybody takes for granted and many don't seem to realize even is a database. So they put a database in their database for storing files within their files. 

Sometimes if you have millions of entries or want to do non-trivial queries that's absolutely merited, but for a small blog/wiki/digital garden thing, it's more like some tired old Xzibit meme from 2010 that serves to add complexity for no reason.

Filesystems are also complemented well with git.

Every time I create, edit, move, rename, or anything on the memex; a commit is pushed to a local repository.  There are currently 853 commits in the log. This means I don't have to worry too much when making changes. They can always be reverted.

Having everything backed by files is great for portability. I could throw away the entire memex rendering software, as long as I keep the data, it's trivial to render a website from it.  This will as be true in twenty years as it is today.

## 2. Hypertext

So we have a bunch of files in a filesystem. So far, so FTP. 

A drawback with a filesystem model is that it does require a modicum of organizational effort, and sometimes if you have extremely large filesystems it's easy to misplace files, but for a small system like this I don't think that is even a concern.

To aid with this, and enable easier navigation between related documents, it's neat if documents could link to each other. 

Each document is made to be hypertext. Documents may refer to each other by their filesystem path. A link text may add context to the link.  To prevent a gradual build-up of dead links, whenever a file is deleted or moved, a line is automatically added to the special files

* [/special/tombstone.gmi](/special/tombstone.gmi)

* [/special/redirect.gmi](/special/redirect.gmi)

These files are used to render a ghost of the (re)moved files allowing the possibility of adding context as to what has happened to the resource. 

To be clear, these /special/-files are not just a rendered representation of magical hidden database somewhere.  It's a basic hypertext document with links.  Everything is a file.  Everything about the system is encoded in hypertext.  Documents are related with links.  Link text encodes semantics about the relationship. A list of links with associated link texts is homomorphic to a k-v store.  Everything is human readable.  This is not just a presentation layer thing.  It's turtles all the way down.

## 2.1 Backlinks are cool

Unlike what you might expect from hypertext coming from the WWW, links are considered weakly bidirectional within the memex. That is, they reflect information not only about the source, but the destination. When rendering, the full link graph is constructed, and backlink information is added to the destination files as well.

Some of the consequences of doing this are unexpected. To illustrate the sort of things you can do with backlinks, the memex uses them to allow for topical categorization.

For example, given the document you are presently reading is about to link to


it's categorized as a web-design-related document! What you see when you click that link is a list of backlinks. 

It would be tempting to abandon the filesystem metaphor and replace it entirely with just a graph of documents linking to each other, although that presents the problem of ... how the heck do you refer to other documents if they have no path? Like you can give them UUIDs or something like that, I suppose, but that system would only make sense to machines. 

The beauty (and explicit design goal) of the memex is that it's just as human readable as it is machine readable. You could print the raw data for the memex on paper and still be able to make sense of it. 

## 3. The remaining owl

The raw sources for the documents are written in a markup language that is a variant of gemtext. The extended gemtext is rendered to HTML (for https://memex.marginalia.nu/ ) and standards compliant gemtext (for gemini://marginalia.nu/ ) whenever a file is created or changed.

To get a feel for the gemtext format, here is an overview:

* [Gemtext Overview](https://gemini.circumlunar.space/docs/gemtext.gmi)

The memex uses some extensions in the form of rendering hints that are stripped away when serving the files over gemini. These may direct the renderer to for example generate an Atom feed for a particular directory, or to inline the file listing.

If a directory contains an index.gmi file, it's served along the directory listing.

Updating the memex is a bit slow (usually takes up to a second) since it essentially requires traversing the entire link graph and re-rendering multiple documents and then doing a git commit. The slowness ends there however. Since everything is statically generated, serving traffic is very fast and the server's survived some pretty ridiculous traffic spikes.

This web design is admittedly unconventional, and I fully appreciate it is not immediately obvious how to navigate the website as a consequence.  This is in part a deliberate effort to challenge web design conventions.  I experience a degree of genre fatigue with the blog format, the wiki format, and so on.

It feels like many of these conventions were instituted decades ago for reasons that are largely since forgotten, and nobody's bothered to challenge them since. What if they're no longer valid, those reasons? That's what the memex is about. To violently shake things and see if something comes loose. 

## See Also

* [/log/43-pseodonymous.gmi](/log/43-pseodonymous.gmi)
* [/projects/memex.gmi](/projects/memex.gmi)

* [The Gemini Protocol](https://gemini.circumlunar.space/)