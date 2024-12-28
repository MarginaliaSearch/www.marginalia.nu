---
title: 'How to remove ghostty''s gnome aesthetic on Linux'
date: '2024-12-28'
norss: true
---

Ghostty by default looks like a gnome app even outside of gnome, with a
hamburger menu and complete disregard for the system theme. 

Put the values below in the config file, which for me was in `.config/ghostty/config` ; 
and then close every ghostty window and restart the application for the changes
to take effect.

```
  window-theme = system
  gtk-titlebar = false
  gtk-wide-tabs = false
  gtk-adwaita = false
```

