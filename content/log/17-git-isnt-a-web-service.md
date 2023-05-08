+++
title = "Git Isn't A Web Service"
date = 2021-08-28
section = "blog"
aliases = ["/log/17-git-isnt-a-web-service.gmi"]
draft = false
categories = []
tags = ["platforms"]
+++


This an expansion on a comment I left on Lettuce's gemlog post, "Personal Experiences and Opinions on Version Control Software". 

I've seen similar questions posed several times recently, in essence people searching for a good git provider. 

The thing is you don't need a git provider. Git is a shell command, and you can host a server yourself with almost no extra work. You can even host it off a system you don't have administrative access to. 

It's a shame git has become synonymous with this large web-application overgrowth for so many these days. It is and remains a fairly complete shell command, and github and its clones are third party extras that have latched themselves onto the ecosystem and seem to be doing their best sucking the life out of it through gamification and other morally questionable startup practices.

Remember sourceforce, once the paragon of everything open source, remember when they were bought up and subsequently caught with their fingers in the cookie jar bundling malware with the software on their site? The lesson we should have learned wasn't "lets move everything from one huge platform to another huge platform"; but rather the lesson was that we so desperately need to learn was that we should host or projects ourselves if we want to retain any sense of control over them. 

## Set-up 

Self-hosting git is extremely easy to set up. You need a raspberry pi or any computer with ssh access and git. 

I linked to the official documentation below, but the really quick way to get started is to do this on the server: 

```
$ mkdir my-project
$ cd my-project
$ git init --bare
```

And then you do this on the client from your existing git project: 

```
$ git remote add origin git-user@server:my-project
```

If you want to move from one existing remote to your new server, you use 'set-url' instead of 'add'. 

That's it! Now you have an off-site backup for your code.

If you want a web interface for sharing your code more publicly, something like gitweb is a good alternative to gitlab and similar, it's much more lightweight (and a bit barebones), but also very easy to set up. Please refer to the git book links below for instructions. 

## Links

* [gemini://gemini.ctrl-c.club/~lettuce/git-services.gmi](gemini://gemini.ctrl-c.club/~lettuce/git-services.gmi)

* [Git Book: Getting Git On A Server](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server)
* [Git Book: GitWeb](https://git-scm.com/book/en/v2/Git-on-the-Server-GitWeb)

