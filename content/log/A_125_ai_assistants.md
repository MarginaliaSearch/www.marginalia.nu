---
title: 'The CoPilot productivity paradox'
date: '2025-09-06'
tags:
- programming
---

I've been using the CoPilot plugin for IntelliJ on and off for the last few years,
and while initially pretty enthusiastic,
I've come to first disable it and then delete it altogether along with JetBrains' local AI-completions,
and generally felt this has been an improvement in productivity and a reduction of frustration.

CoPilot is pretty good at taking things that are already pretty fast,
such as monotonous code transformations like mapping an object to a SQL statement,
and then making that even faster.

This is at first glance neat as this category of tasks often feels like chores,
and if this was all the plugin did it would be hard to build a convincing case against CoPilot.

The drawback is that it often suggests things that are at best not very useful,
and often straight up distracting.

Evaluating and dismissing these noisy suggestions requires mental bandwidth,
which is a finite resource and generally the biggest bottleneck in programming.

With CoPilot suggestions,
the code keeps changing in significant ways prompted not by the programmer but by the code assistant.
This means the mental model of the code constantly needs to be updated,
and such mental model thrashing is exhausting.
Needless to say coding while tired produces worse code regardless of CoPilot involvement.

This is different from a CoPilot-free workflow where the mental model doesn't constantly need invalidation,
and where the code remains what has been deliberately typed into the editor.

An IDE can be incredibly productive when you have fast and deterministic suggestions,
which rapidly turn into a form of shorthand that don't require more than muscle memory.
Working this way the path between intention and code on screen is very short, and feedback is immediate.

This falls apart completely when CoPilot-assisted coding is introduced to the loop,
muscle memory simply doesn't work when the suggestions are not deterministic and when there is a noticeable and variable processing delay of several hundred milliseconds.

Considering and fixing half-correct suggestions is surprisingly time consuming,
not just from the need to read and understand unfamiliar code, 
but going over it to fix all the small little problems that cropped up often takes as long as just writing the code correctly in the first place.

The position I'm leaning toward is that bolting on LLM suggestions as a drop-in replacement for classic IDE-suggestions is a bad idea that doesn't make good use of neither the LLM's capabilities nor the programmers'.

As an experienced programmer,
you can get most of the benefits and none of the drawbacks from CoPilot by putting in the effort to learn to type faster,
or to make better use of the editor with e.g. vim motions,
this increases your speed without eating into the mental bandwidth needed to solve programming problems.
This is perhaps less glamorous and definitely more work,
but it's not impossible and certainly a project that pays off in the long run.

The faults of CoPilot are arguably more of an integration problem than a model problem.
Putting LLMs *in* the editor is likely simply not a very good idea as long as the operator of the editor is a human being.
They seem to work best as a separate chat interface where you have explicit control over the context.

Interrogating an LLM about a particular problem or piece of code generally works very well,
as does requesting the draft sketch of a solution to some problem that can be manually refined to fit the parameters.
This caters well to the strengths of both the programmer and the model,
where context is explicit and information transfer infrequent and happens in bulk. 

All this is in the context of over two decades of programming experience and deep understanding of the programming language itself,
CoPilot and similar do offer some benefits when working with unfamiliar languages.
Sometimes it's necessary to work in languages you are less familiar with,
and waiting for an expert level understanding of the language before you start writing any code is time consuming indeed,
and in such a situation the value proposition is likely different.

As usual, these are my experiences from my particular context, and your mileage may very well vary.
