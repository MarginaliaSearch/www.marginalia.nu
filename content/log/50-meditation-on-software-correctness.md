+++
title = "A meditation on correctness in software"
date = 2022-03-14
section = "blog"
aliases = ["/log/50-meditation-on-software-correctness.gmi"]
draft = false
categories = []
tags = ["programming"]
+++


Let's define a simple mathematical function, the function will perform integer factoring. It will take an integer, and return two integers, the product of which is the first integer. 

  F(int32 n) = (int32 A, int32 B) 

so that 
  
  A*B = n

This is fairly straight forward, mathematical, objective. Let's examine some answers an implementation might give.

  F 50 = (5, 10) on ARM
  F 50 = (10, 5) on Intel

This seems like a bug, so let's add the requirement that A <= B for deterministic results.
  
Depending on language what comes next may or may not be defined behavior, but let's use a programming language where signed integers overflow, then we might get this result:
  
  F 2 = (-2, 2147483647)

Now, as everyone no doubt will recognize, 2147483647 is a Mersenne prime (2^31 - 1), and the answer satisfies every requirement posed so far. This again *seems* like a bug, we clearly meant to say A and B must be positive.

New scenario! F(60):
  
  F 60 = (2, 30) on most days
  F 60 = (1, 60) on the programmer's birthday
  F 60 = (5, 12) during monsoon season
  F 60 = (6, 10) when venus is in retorgrade
  
Yet again, this seems wrong, we don't expect a mathematical function to depend on the calendar. Perhaps we meant that A must be the lowest prime factor.

Let's consider F(7)

  F 7 ?= (1, 7) -- no, 1 isn't a prime
  F 7 ?= (7, 1) -- no, 7 is greater than 1
  F 7 = error!
  
These requirements are impossible to satisfy when n = 7. What we meant to say was that A must be a prime factor, or 1 if n is prime.

That actually still leaves F(1):

  F 1 ?= (1,1) -- no, A=1 isn't a prime, and B isn't a prime so A isn't permitted to be 1.

So now A must be a prime factor, or 1 if n is a prime or 1.

Let's leave those particular weeds and consider F(-4)

  F -4 ?= (-2, 2) -- no, -2 isn't a prime
  F -4 ?= (-4, 1) -- no, -4 isn't a prime
  F -4 ?= (1, -4) -- no, A > B
  F -4 ?= (2, 2147483646) -- yes!(?!?)

The last entry satisfies every requirement (again in signed integer arithmetic); 2 is a prime and a factor or -4, the smallest, 2 is less than 2147483646, 2 is positive. ... yet it feels like a bug. Let's just do like Alexander and bring a sword to this knot and require that n > 0, this also gets rid of the degenerate zero case. 

Some reader may object and say this is because of signed integers, but believe me, floating point isn't better, fixed point has gotchas as well. This post isn't really about integers, it's about our relationship to requirements. 

While the requirements may seem simple, the function may strictly speaking open a socket to some SaaS-service that performs prime factoring. From the requirements it's impossible to tell. It would be unexpected for a factoring function to run out of file descriptors or not work during a network outage, but given the requirements provided so far, it might; and we might call that a bug too.

This is how software development goes, on all levels, low level programming, high level programming, front-end programming, back-end programming.

What I want to argue is that this is something that happens a lot: Bugs, more often than not, aren't a breaches of requirements, but rather the code surprising us in some fashion, upon which we quickly invent some new implicit requirements the code is breaking that we would not have been able to tell you before the discovery of the bug.

Software correctness is indeed praised by many, but in many cases it's not entirely clear what it even means for software to be correct. In reality, it often boils down to some hand-wavy principle of least surprise, where a staggering amount of software requirements are entirely made up on the fly in response to the behavior of the code. 

You may violently disagree with the inflammatory accusation that comes next, but if this is the case, is there any other word for software that repeatedly surprises its users through frequent design changes than this?: Buggy.

