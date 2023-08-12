---
title: "Message Queues, State Machines, Actors, UI"
date: 2023-08-12
distinguished: 0
tags:
- "nlnet"
- "search-engine"
---

This is a bit of an *what I've been working on* style of post.  It's also a bit of a complement for the
release notes of the upcoming release which should be dropping in a week or so.  There's some spit and
polish still missing from these things, but if I don't write about them now too much will have been
ejected from the cache to make a well written post about it.

Thus far the problem of automation in Marginalia Search has largely been "solved"
through manual orchestration.  Crawling, processing, loading index data is a 2+ week long manual
process with a long run book that has a lot of moving parts and many steps, including
files that need to be moved into particular locations, services that need starting and
stopping at particular times, and so so forth.

Manual operation actually is surprisingly resilient since having a human operator means 
the system state is fairly well known at every point and deviations from the expected path 
can be detected easily and addressed early, but it's also time consuming and error prone 
and has been growing increasingly untenable.  Like so many things, it works until it doesn't.

Automating this process has been a mounting priority for a while and I'm finally getting 
around to it.

When addressing this, I think it's important to have a clear idea of what the problem is
and what we're trying to achieve here, which is automating the processes that are currently
done manually in a way that can deal with basic errors and failures without human 
intervention.  

It's not going to be a zero-maintenance solution, but I'm hoping to get away from the current
situation where not even the sunny day path is automated.  It's desirable to have a the process 
be transparent and easy to understand so that manual recovery is an option if the automated
control flows fail.

It's not just a single process that needs to be automated, but a whole series of processes that 
need to be orchestrated.  These processes occasionally crash, and when we do it's important to be
able to recover from that, or at least be able to understand the state of the system (given the multiple
weeks-long runtime of the overall crawling-processing-loading lifecycle).

A non-goal for this automation is speed.  The process is built out of a series of large granular steps, 
and shaving off seconds between their launch is just not a priority. 

REST, which is used elsewhere in the system is not a great fit for this type of orchestration.
It's hard to track the state of processes, connections time out, and it's difficult to get a 
birds-eye view of the system. A more appropraite paradigm for communication is a message queue.

# The Message Queue 

There are many tools for building message queues, including ready-made services and
libraries, such as RabbitMQ, OpenMQ, Kafka, etc.  These libraries are primarily aimed
at providing robustness under load, which is not a primary concern here. As a result 
they also tend to be fairly complex, and I'm not sure they're a good fit for the 
problem at hand.  Speaking from experience, I have worked with several of these before,
and they generally tend to bit more than what I had in mind.  

The purpose of the message queue we're interested in is to provide a robust and replayable 
way for services to communicate with each other, and to provide a way to recover from 
failures.  With that in mind, we can use a simple SQL database as our backing store,
with the added benefit of being able to use the database as a transaction journal and
being able to use familiar tools form the SQL ecosystem to address errors as they occur.

The system does have just the tool though. The ACID properties of SQL databases can do 
most of the heavy lifting here if we're a bit careful about how we use them. 

The message queue is designed a single table, here shown in an abbreviated form:

Name|Type
---|---
id|long
related id|long
recipient inbox|string
sender inbox|string
state|NEW,ACK,OK,ERR,DEAD
ownerTick|long
ownerUIID|string
(data,metadata)|(various)

There are some concepts to unpack here. 

## Related ID

Each message has a unique `id`, and optionally a `related id`.  The `related id` is used to track
responses or mark messages as related to each other.  In request/response-style messaging, the 
`related id` of the response is the `id` of the request message.  

## Inbox Name

Conceptually the message queue is set up as a series of letter boxes, each representable
as an inbox and an outbox; and each with a unique name.  Outbox Bob can send a message to
Inbox Alice by addressing the message to the inbox named "Alice" with a return address of 
"Bob". 

Alice can then read the message from her inbox.

If she wants to respond, she can send a message to the sender inbox and mark it as related
to the first message.  The message queue will then deliver the message to Bob's inbox. 

These names go in the fields `recipient inbox` and `sender inbox`. 

Messages are in practice sent by inserting them into the message queue table, and a request-response
paradigm is implemented on top of this by having the sender wait for a response message with the same 
`related id` in their inbox.  

## State

The messages each have a state.  The state can be one of the following:

* `NEW` - The message has been created, but not yet received
* `ACK` - The message has been dequeued by the recipient
* `OK` - The message has been dequeued and processed successfully
* `ERR` - The message has been dequeued and processed unsuccessfully
* `DEAD` - The message has been marked as dead, either due to a timeout or a similar failure to process

Being able to track the process of a message, and to distinguish between the `NEW`, `ACK` and `OK`/`ERR` 
state is a huge improvement over REST; which at best can only tell you if a message has been successfully 
processed vs not (or it was actually successfully processed but reported as an error, or there was a 
timeout, or network blip, or whatever).

## Dequeuing with ownerTick and ownerUIID

The owner fields are used to dequeue the message.

These statements are true about the fields: 

* The owner UUID is unique to the instance of the recipient.
* The ownerTick is incremented each time the inbox is polled and is unique within the execution of the instance. 

Thus, to dequeue a message, an update statement like the following is used:

```sql
UPDATE message_queue
WHERE recipient_inbox = 'Alice' 
AND STATE='NEW' AND ownerUUID IS NULL
SET ownerUUID = 'uu-ii-dd', ownerTick = 10, STATE='ACK'
ORDER BY id ASC
LIMIT n
```

Since UPDATEs are atomic, this will avoid race conditions and consistency problems without
having to use lengthy transactions or additional locks beyond the implicit lock from the UPDATE statement.
Minimizing locking is desirable because we're going to have dozens of connections polling this same table 
on regular intervals. 

We can then safely select for the ownerUUID and ownerTick to get the message we just marked.

```sql
SELECT [...] 
FROM message_queue 
WHERE ownerUUID = 'uu-ii-dd'
AND   ownerTick = 10
```

Note that we need two fields to pull off this trick, since ownerUUID is not unique across messages, and 
ownerTick is not unique across instances; only in combination are they unique.  This can be solved using 
only a single field, but it's more computationally expensive and generally difficult to prove that it works 
as intended. 

In practice the inbox will poll periodically for new messages and notify subscribers
if any new messages are found.  The subscribers can then process the messages and
mark them with `OK` or `ERR`.  

Thus far we've implemented a simple request-response message queueing mechanism over SQL.  This seems 
like a sidegrade at best over REST.  It has the advantage of being more robust as well as its own 
transaction journal, but it's also much slower and inherently more complex and doesn't quite solve the 
resilience problem at hand.

To get the full benefit of the message queue, we need to add an abstraction on top of it.

# All the world's a stage, and we are all Actors upon it

There's an old trick among cold war spies and rouges to hide the assets needed for
a getaway in the postage system.  The spy would go to the post office every
week, receive a parcel, and then send it back to himself.  That way, were
their home or office ever ransacked, nothing would ever be found. 

This is pretty smart trick, not only for hiding assets and passports from the KGB, 
but for building software that needs to survive crashes and failures; store
the state in the message queue, and you can always recover from a crash by checking
your inbox. 

In a loose sense, what we're going to implement on top of the message queue is an actor model.  
Such as system is composed of actors which correspond via messages. 

Specifically, the idea is to create a state machine, where each state transition is mediated 
via the message queue previously drafted.  Each state transition is implemented as a function
that returns a tuple containing the next state and an optional parameter.  

The system takes a message from the message queue, performs the corresponding action, and then sends itself 
a message containing instructions about what to do next. Rinse and repeat until a terminal state is reached.

The actual state machine is implemented as a dictionary of transitions/functions, where each function
takes the current state and the message arguments as input, and returns a transition to
the next state and the arguments for that state.  

In some sort of light pseudocode it may look something like this:

```java
allStates.put("START", (arguments) -> {
  if (!sanityCheck(arguments)) {
    return ("ERROR", "bad arguments");
  }
  return ("SEND_REQUEST", arguments)
});
allStates.put("SEND_REQUEST", (arguments) -> {
  request_id = sendRequest(arguments)
  return ("WAIT_FOR_RESPONSE", request_id)
});
allStates.put("WAIT_FOR_RESPONSE", (request_id) -> {
  response = waitForMessage(request_id)
  return ("END", response)
});
// ...
```

The state machine itself is then implemented as an inbox subscription:

```java
inbox.subscribe((msgId, related_id, state, arguments) -> {
  // reject messages with the wrong related id
  if (related_id != expected_id)
     reject();
  
  // fetch the state definition
  state = allStates.get(state)
  
  // execute the state transition 
  (nextState, nextArguments) = state.transition(arguments)

  if (state.isTerminal()) {
    return // we're done
  }

  // update the related_id to the new message id
  expected_id = msgId

  // send a message to self to trigger the next state
  outbox.send(ownInboxName, expected_id, 
              nextState, nextArguments)

});
```

We use the related id field to ensure that we don't get spurious state transitions, 
the state machine will only accept messages with the correct related id.  

We can recover from crashes by simply looking at the last message we received.  If it's 
in message state 'NEW' we can act on it accordingly, and if it's in 'ACK' we know
processing was interrupted, and depending on the nature of the step we can either retry it
or abort the process. 

The 'WAIT_FOR_RESPONSE' above is a prime candidate for resuming on recovery, 
and the 'SEND_REQUEST' is a case where it's hard to say without manual intervention
what the state of the system is, and aborting is probably an advisable "recovery" action.

This is a very powerful pattern, but as with state machines in general, it's finicky and 
easily degenerates into a turing tarpit where "anything is possible but nothing is easy".
Another drawback is that for reasons that boil down entirely to the JVM, there can
be no compile time type checking.  

To avoid the problems inherent in this, in general it's a good idea to keep the state machines
as simple as possible with clear and simple flows and few states.  As long as this stricture
is heeded, you can now build crash tolerant systems.  It's important to keep in mind why this
mechanism was put in place, to build fault tolerant processes.

Longer more complex flows can be implemented by having state machines trigger each other
via a request-response type flow, since the message queue is already set up to handle that
and waiting for a response is a recoverable action.  

One way this is done is by having monitor actors that eavesdrop on the message queue and 
spawn processes when they receive a message, if they are not already running that is.

# Putting in the pieces

So this has all been built. It sounds like a lot of work but it's much less than you'd expect. 
The entire message queue and actor library is about 1500 lines of code. It's the same size as 
the code for the actors implemented with it.  

The code integrating this into the system and providing an operator's interface
for the search engine is actually *much* bigger than this little middleware library.

In planning this work I had set off 4 weeks for the message queue and state machine stuff,
and 2 weeks for the UI.  It turned out to be the other way around... which I guess in hindsight
I should have been able to predict this outcome.  UI stuff is always time consuming and slow 
to get right. 

Building an interface for this that makes sense, while retaining a high degree
of flexibility has proven the bigger challenge.  I took an approach of exposing the
functionality in layers of abstractions; from direct inspection and access to the message
queue, to the ability to view and inspect the Actors, to an even higher layer that offers
work flows for doing basic tasks without a PhD in the internal architecture of the system.

So far the operator's UI does this:

* Inspects the message queue (and permits edits/additions)
* Provides an event log and status of the processes and services
* Provides a way of terminating and disabling actors 
* Offers a GUI for adding API keys
* Offers a GUI for managing the blacklist
* Offers a GUI for managing complaints
* Offers a GUI for managing data from crawls etc.
* Offers means of triggering a crawl
* Offers means of triggering a re-crawl (re-visit websites using existing crawl data for ETag etc)
* Offers means of processing crawl data (automatically or explicitly)
* Offers means of loading crawl data (automatically or explicitly)
* Offers various buttons for flushing caches

It's still rough around the edges, and I expect I'll need one or more passes to sand
down all the pointy corners, but it's starting to come together.  

Since the release cycle is driven by the inexorable pace of the crawl-process-load cycle
(which is wrapping up), the next release may be in a bit of a weird place because it has 
this 90% done user interface, but it's still a lot better than what came before as I now 
have a basic GUI for a lot of the things that I was previously doing by hand, sometimes 
by directly typing SQL-commands into the db client.

The new release should drop in about a week or so, fingers crossed.