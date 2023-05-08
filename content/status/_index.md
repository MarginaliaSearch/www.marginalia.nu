---
title: "Server Status Log"
---

Marginalia.nu server maintenance status log. You may have been redirected here during an outage. 
If this page reports the server as up, try revisiting [https://search.marginalia.nu/](https://search.marginalia.nu/).

If it still does not work, please reach me at kontakt@marginalia.nu or @MarginaliaNu on twitter.

<hr>

Current known issues:<br>
<ul>
  <li> Year based queries are not working </li>
  <li> The 'vintage' and 'blog' profiles are broken. </li>
  <li> Some queries are a bit slower than expected. </li>
</ul>
Patches:
<ul>
  <li>(2023-04-13) Patch 1: Disable Web 1.0 filter and temporarily disable blog profile's recency bias, as a work around
							for the currently somewhat corrupted document metadata with no usable year-information. </li>
  <li>(2023-04-15) Patch 2: Fix bug where <tt>tld:</tt> and <tt>links:</tt>-style queries weren't picked up due to
							how queries were constructed. </li>
</ul>