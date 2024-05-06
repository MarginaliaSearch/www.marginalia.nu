---
title: 'Using DuckDB to seamlessly query a large parquet file over HTTP'
date: 2024-05-05
tags:
- programming
---

A neat property of the parquet file format is that it's designed with block I/O in mind,
so that when you are interested in only parts of the contents of a file, it's possible to
some extent to only read that data.  Many tools are aware of this property, and DuckDB
is one of them. Depending on which circles you run in, a lesser known aspect of HTTP 
is range requests, where you specify which bytes in a file to be retrieved.  It's possible
to combine this trio of properties to read remote parquet files directly in DuckDB.

I've had these facts things in the back of my head for a while, but saw the opportunity 
to put them in to practice recently when extending the admin GUI for marginalia search 
to add the option to inspect remote crawl data. 

Normally I'd ssh into the server and use DuckDB to interrogate the relevant parquet files,
but this is a bit unwieldy.  At the same time I wasn't particularly keen on building an 
internal API for pushing the crawl data to the admin GUI.  That sort of plumbing is just 
annoying to maintain and makes the system push back against future change efforts, it's 
bad enough the data needs modelling to be presented in the GUI itself. 

There was already an HTTP endpoint for moving files between services, and amending it to 
understand range requests turned out to be very quick.  

A longer outline of what the range header does is available on [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests), 
but in brief, an HTTP server can announce support for range requests by sending the response header 
'Accept-Ranges: bytes'.  When this is seen by the client, it may send a request header 
'Range: bytes=nn-mm',  and then the server should respond a HTTP 206 and only send those 
octets.  Only major caveat in implementing this is that the range is inclusive. 

With that in place, it's possible to query the URL in DuckDB as though it was a database table: 

```
select count(*) from 'http://remote-server/foo'
```

You can do this with other formats than parquet, but in many of those cases it will need 
to download the entire file in order to perform the query.

In practice, DuckDB seems to probe the endpoint with a HEAD first, presumably to sniff out 
the Accept-Ranges header, and then it proceed with a series of range requests to fetch the 
data itself. 

DuckDB integrates very easily into many programming languages.  In Java you can use 
JDBC to query it like any SQL data source, python has a very good integration as well.

While I wouldn't recommend using this method to build anything user-facing, it's 
definitely a bit slow where doing larger queries on parquet files in the 100MB+ 
range may take a few hundred milliseconds, it does a remarkable job for this 
particular task.  

Part of why I wanted to share this is that it's pretty rare that technologies 
click together this effortlessly.  DuckDB in general keeps surprising me with
these unobtrusive low friction integrations.  

It's in stark contrast to the other ways of reading parquet files in Java, 
which typically requires you to pull in half the Hadoop ecosystem before the code will 
even compile.  

Someone built a very limited compatibility layer called 'parquet-floor' 
that cuts most of the Hadoop ties, and but it's very limited.  I've been slowly 
extending it with new capabilities, but it's still a very high friction environment.  

The most reliable way I know of making ChatGPT look incompetent is to ask it how to
read a parquet file in Java without Hadoop.  This is arguably mostly a reflection on
the quality of information available regarding this task.

This isn't to fling crap on the Hadoop people, whom absolutely nobody has put in charge 
of maintaining universal parquet support for Java, even though theirs seems to have become 
the de facto default implementation somehow. 


