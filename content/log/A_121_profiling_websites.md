---
title: 'Profiling Websites'
date: 2025-05-29
tags:
- nlnet
- search-engine
---


The most recent change to the search engine is a system that profiles websites based on their rendered DOM.  The goal is identifying advertisements, trackers, nuisance popovers, and similar elements.

The search engine already tries to do this, but isn't very good at it because it's only looking at static code.

It turns out to be somewhat difficult to determine what a website that has non-trivial javascript will look like based its source code alone, as this would require us to among other things solve the halting problem.

The simple way around this is to use brwoser automation to actually render the website.  This is on the other hand very expensive for both client and server,  so it's not really feasible to use in crawling unless you want the entire Internet to hate you, making it more suitable for a separate sampling and analysis track.

Although stopping at just the rendered DOM isn't quite giving enough information, as often a lot of the information we need is in the style sheets, some popovers don't load until we've moved the mouse in a certain way, and so on.

The solution is building a custom browser extension loaded into the headless browser.  This lets us export the effective styling of the elements, where 'position' and 'display' are perhaps the most important attributes.  This makes identifying popovers fairly easy.

Browser extensions are fairly easy to create, and can be quite powerful.  They let you both inject javascript code into the website itself, as well as construct background workers that are capable of injecting events into the website. 

To provide the information needed for analyzing websites, an extension was created that does the following:

### 1. Background script subscribes to reload events

There seems to be a limitation in browser extensions where if a document reloads itself, the content script isn't loaded.  This can thankfully be worked around via a background worker, which can re-inject the content script.

### 2. Background script subscribes to network requests

The background script also intercepts all network traffic and feeds them as events to the content script, which will keep them in memory.  We're interested in figuring out which servers the website talks to, particularly ad brokers and trackers. 

### 3. Content script simulates user behavior

After the load event, the content script simulates some user behavior.  The mouse is moved to the address bar, and the page is scrolled down.  This is an attempt to trigger newsletter subscription popovers that only appear after "exit intent".

Then the script pauses for 2 seconds.

### 4. Content script looks for popovers that may be cookie consent-related

After the two second pause, the script looks for cookie consent popovers.  If it finds them, it attempts to give cookie consent, as at least in GDPR-land, ad networks often don't load until after you've done this.  If a popover was found, the script pauses for another 2 seconds as we capture the burst in network traffic as the ad networks load.

### 5. Content script saves effective CSS and network traffic into attributes in the DOM

Next, each element in the DOM is inspected, and those with changes in 'display' or 'position' CSS attributes have this information written into custom data-attributes in the DOM.

The log of network traffic we've seen is also written into a new div in the DOM, as well as information about whether we've accepted a popover.

Finally this is exported from the browser, and the network request data is removed from the DOM and saved separately. 

It's quite hard to show exactly what the export looks like, as its just an unwieldy blob of HTML, but to give some illustration of the data capture, this is an excerpt from the extension when applied to this website.  Note that `data-display` was added by the script.
```html
<footer data-display="block">...</footer>
<div id="marginalia-network-requests">
  <div class="network-request" 
    data-url="https://www.marginalia.nu/css/style.css" 
    data-method="GET" 
    data-timestamp="1748519992782"></div>
  <div class="network-request" 
    data-url="https://www.marginalia.nu/fonts/PlayfairDisplay-Regular.ttf" 
    data-method="GET" 
    data-timestamp="1748519992814"></div>
  <div class="network-request" 
    data-url="https://www.marginalia.nu/fonts/PlayfairDisplay-Regular.ttf" 
    data-method="GET" 
    data-timestamp="1748519992834"></div>
  <div class="network-request" 
    data-url="https://www.marginalia.nu/favicon.ico"
    data-method="GET"
    data-timestamp="1748519992843"></div>
</div>
```

Test driving this extension in a real browser to iron out bugs has been an interesting experience.  The simulated user behavior (in particularly the scrolling) is of course very annoying, but it's also remarkably stable and good at what it does.  

Currently the sampler is capturing about 10,000 domains per day, so it will be several months before the body of data is big enough to be of much use, but that is the case with search engine work in general, a lot of these things simply need their time in the oven.

Toward the end of the year the plan is to incorporate the data into the ranking algorithm, as well as make an export of the profiling data available for public download.
