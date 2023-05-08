+++
title = "Wasted Resources"
date = 2021-12-04
section = "blog"
aliases = ["/log/40-wasted-resources.gmi"]
draft = false
categories = []
+++


At a previous job, we had a new and fancy office. The light switches were state of the art. There was an on button, and a separate off button. When you pressed the on button, the lights would fade on. When you pressed the off button, they would fade off. In the cloud somewhere was two functions that presumably looked a bit like this:

```
fun turnOnLamp() {
  while (!bright()) increaseBrightness();
}
fun turnOffLamp() {
  while (!dark()) decreaseBrightness();
}
```

I have deduced this from the fact that if you pressed both buttons at the same time, the lights would flicker on and off until someone was contacted to restart something. It is a marvellous time to be alive when you need to reboot your light switches because of a race condition. Modern computers are so fast that we often don't even recognize when we are doing things inefficiently. We can end messages half way around the world to turn on the lights and it seems like it's just a wire between the switch and the lamp.

In my code there was a performance snag recently with a piece of logic that used Java streams quite liberally. I had written it that way beacuse this logic was pretty hairy and streams can be a lot more expressive, and I tend to prioritize that in the first version of the code and go and optimize later when necessary.

The code iterated over an array and looked for spans that matched a combination of criteria. Imagine a couple of dozen constructions of this general shape:

```
  return IntStream.range(1, words.size())
           .filter(i -> predA(sentence, i))
           .filter(i -> predB(sentence, i-1))
           .filter(i -> predC(sentence, i-2))
           .map(i -> new Span(i-2, i+1))
           .toArray(Span[]::new);
```

I replaced it with code of the form

```
  ArrayList<Span> ret = new ArrayList<>();
  
  for (int i = 2; i < words.size(); i++) {
    if (predA(sentence, i) && predB(sentence,i-1) && predC(sentence,i-2)) {
      ret.add(new Span(i-2, i+1));
    }
  }
  
  return ret.toArray(Span[]::new);
```

The code was about an order of magnitude faster as a result. I do feel a bit uneasy about this. If it wasn't for the fact that I work with humongous datasets, I wouldn't have noticed there was a difference. Both are fast on a modern CPU. Yet, a lot of the code we write simply isn't as fast as it could be, and while speed may not be the biggest deal, it's consuming resources, both system resources and energy.

I do think Parkinson's law is applicable. The inefficiency of the code grows to meet the performance of the hardware. This is probably why user interfaces today hardly seem faster than they did 25 years ago. Back then they were slow because they read data off a floppy disk, today they are slow because they are executing 40 megabytes of javascript and sending data across the entire world to render a button. 

I've always felt that targeting slow hardware makes your code better on all systems. If it performs well on a raspberry pi, it performs well everywhere under any circumstances. 