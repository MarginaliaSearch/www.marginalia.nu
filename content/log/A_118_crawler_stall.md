---
title: 'Debugging A Crawler Stall'
date: 2025-04-22
tags:
- programming
---

Some time ago, I migrated the crawler off the okhttp library, to use
Java's builtin HTTP client.  This seemed like a good idea at the time,
but has led to a fair number of headaches.

Java's HttpClient has one damning flaw, and that that it doesn't support socket timeouts.  

Its only supported timeout values are time to connect, and time until first byte of the response.  This means the client can get stuck on a read call if a server stops responding, potentially for a very long time!

You can work around this by wrapping each call in a thread and interrupting that thread on a timer, but this is both wasteful and annoying, and I can't find any other HTTP client library that doesn't permit socket timeouts to be set anywhere I look.

The stuck server may be a fairly academic scenario in most circumstances, but for a web crawler it's very real scenario (and sometimes a malicious attack).  Because of this, and other smaller annoyances, I ported the crawler over to Apache's HttpClient, which is fairly similar in both name and design, but a lot more competent... and easier to mess up.

The actual migration was fairly smooth.  I built a battery of new tests, found some bugs, fixed them, tested the thing locally against my own websites. Seemed to work.  So after shaking it down some more I put it in production.

**That's when the problems began.**

In short, the crawler ran for about 3 minutes and than came to a halt with deafening silence in the logs... and then a few minutes later, a ton of error messages.  

I immediately assumed the problem was a resource leak, as Apache's HttpClient has you doing a fair bit of manual freeing up of resources, which might lead to the connection pool filling up.  

I did a thread dump and it seemed like every thread I looked at was stuck trying to lease a connection, so it seems plausible.

I did identify one instance where a resource wasn't properly freed, in the sitemap retrieval code, deployed to prod again and... it did the same thing!  Crawled for a few minutes, then a grinding halt, and then a few minutes later a bunch of errors.

I looked over the code again, scrutinizing every execution path but damnit i just couldn't find where any resources were leaking.  What the heck?  

At this point I added a thread that periodically dumped out the connection pool stats.  I resumed the crawl, and got some numbers.  

It gave me two weird results:

* The pool was 95% vacant
* The statistics stopped coming when crawling stopped

At this time I did a new thread dump to see what was going on with the statistics stopping.  
Still 90% of the threads stuck trying to lease a connection.  ... but also a few threads stuck trying to return a connection.  And one thread stuck trying to close a connection (while holding a connection pool lock)?!  (stack trace excerpts at the end of the post)

From this it was fairly easy to identify that the culprit was `SO_LINGER`, which has the almost unique ability to make `close()` into a blocking call.  

In brief it configures what to do with unsent data as you close a socket.  By default it tries to send it in the background, but you can also set it to discard the data and abort the connection, or in my case, try to send it for 15 seconds while close blocks.

I'd set it to 15 seconds, but for reasons beyond my comprehension, it seemed to block much longer than that.  To be honest I'm not entirely sure why this happens, but regardless, disabling `SO_LINGER` immediately fixed the symptoms.  

It seems like a minor design oversight to close a connection in a critical section, though it's likely this issue is one that you only run into trying to manage thousands of connections with library code that likely isn't designed for that scale.

Overall the crawler seems quite a bit healthier with Apache's HttpClient.  It's quite pleasant to work with, despite the change's initial teething problems.


## The Stuck Thread

```
        at sun.nio.ch.UnixDispatcher.close0(java.base@24.0.1/Native Method)
        at sun.nio.ch.SocketDispatcher.close(java.base@24.0.1/SocketDispatcher.java:70)
        at sun.nio.ch.NioSocketImpl.lambda$closerFor$0(java.base@24.0.1/NioSocketImpl.java:1207)
        at sun.nio.ch.NioSocketImpl$$Lambda/0x00000000ac2e7da0.run(java.base@24.0.1/Unknown Source)
        at jdk.internal.ref.CleanerImpl$PhantomCleanableRef.performCleanup(java.base@24.0.1/CleanerImpl.java:170)
        at jdk.internal.ref.PhantomCleanable.clean(java.base@24.0.1/PhantomCleanable.java:96)
        at sun.nio.ch.NioSocketImpl.tryClose(java.base@24.0.1/NioSocketImpl.java:841)
        at sun.nio.ch.NioSocketImpl.close(java.base@24.0.1/NioSocketImpl.java:896)
        - locked <0x00007f9d86192618> (a java.lang.Object)
        at java.net.SocksSocketImpl.close(java.base@24.0.1/SocksSocketImpl.java:511)
        at java.net.Socket.close(java.base@24.0.1/Socket.java:1629)
        - locked <0x00007f9d86192608> (a java.lang.Object)
        at org.apache.hc.core5.io.Closer.close(Closer.java:48)
        at org.apache.hc.core5.io.Closer.closeQuietly(Closer.java:71)
        at org.apache.hc.core5.http.impl.io.BHttpConnectionBase.close(BHttpConnectionBase.java:268)
        at org.apache.hc.core5.http.impl.io.DefaultBHttpClientConnection.close(DefaultBHttpClientConnection.java:71)
        at org.apache.hc.client5.http.impl.io.DefaultManagedHttpClientConnection.close(DefaultManagedHttpClientConnection.java:176)
        at org.apache.hc.core5.pool.PoolEntry.discardConnection(PoolEntry.java:180)
        at org.apache.hc.core5.pool.StrictConnPool.processPendingRequest(StrictConnPool.java:334)
        at org.apache.hc.core5.pool.StrictConnPool.lease(StrictConnPool.java:209)
```

## Almost Everything Else

```
        at jdk.internal.misc.Unsafe.park(java.base@24.0.1/Native Method)
        - parking to wait for  <0x00007f9d56d68000> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
        at java.util.concurrent.locks.LockSupport.parkNanos(java.base@24.0.1/LockSupport.java:271)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquire(java.base@24.0.1/AbstractQueuedSynchronizer.java:791)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer.tryAcquireNanos(java.base@24.0.1/AbstractQueuedSynchronizer.java:1077)
        at java.util.concurrent.locks.ReentrantLock$Sync.tryLockNanos(java.base@24.0.1/ReentrantLock.java:169)
        at java.util.concurrent.locks.ReentrantLock.tryLock(java.base@24.0.1/ReentrantLock.java:480)
        at org.apache.hc.core5.pool.StrictConnPool.lease(StrictConnPool.java:195)
```
