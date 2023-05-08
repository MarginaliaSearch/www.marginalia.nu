+++
title = "Experimenting with Personalized PageRank"
date = 2021-10-02
section = "blog"
aliases = ["/log/26-personalized-pagerank.gmi"]
draft = false
categories = []
tags = ["search-engine"]
+++


The last few days I've felt like my first attempt at a ranking algorithm for the search engine was pretty good, like it was producing some pretty interesting results. It felt close to what I wanted to accomplish.

The first ranking algorithm was a simple link-counting algorithm that did some weighting to promote pages that look in a certain fashion. It did seem to keep the page quality up, but also seemed to as a strange side-effect promote very "1996"-looking websites. This isn't quite what I wanted to accomplish, I wanted to promote new sites as well as long as they were rich in content.

This morning I was reading through the original paper on PageRank, an algorithm I had mostly discounted as I thought it would be too prone to manipulation, mostly based on Google's poor performance. I had done some trials earlier and the results weren't particularly impressive. Junk seemed to float to the top and what I wanted at the top was in the middle somewhere.

Then I noticed toward the end the authors mention something called "Personalized PageRank"; a modification of the algorithm that skews the results toward a certain subset of the graph.

The authors claim

>     These types of personalized PageRanks are virtually immune to manipulation by commercial interests. For a page to get a high PageRank, it must convince an important page, or a large number of non-important pages to link to it.

Huh. My interest was piqued.

The base algorithm models a visitor randomly clicking links and bases the ranking of the distribution of where the visitor is most likely to end up.

The modification of the algorithm in simplicity introduces a set of pages that a hypothetical visitor spontanenously goes back to when they get bored with the current domain. The base algorithm instead has the visitor leaving to a random page. In the base algorithm this helps escape from loops, but in the modified algorithm it also introduces a bias nodes pages adjacent to that set. 

I implemented the algorithm. PageRank is a very simple algorithm so this wasn't more than a few hours. I used my own memex.marginalia.nu as the set of pages the bored visitor goes to, as it has a lot of links to pages I like. The algorithm ran for a few seconds and then converged into something beautiful: A list of small personal websites.

No, wait. This doesn't cut it.

## Jesus. H. Christ. On. An. Actual. Penny. Farthing. What. I. Don't. Even. HUH?!

The top 1000 results were almost ALL personal websites, like of the sort that was actually interesting! It's... it's the small web! It's the living breathing blogosphere! It's *everything* I wanted to make available and discoverable! I did some testing on a smaller index, and it actually kinda worked. I pushed it into production, and it works. It's amazing!

What's great is that even though I didn't plan for this, my search index design allows me to actually roll with *both* algorithms at the same time; I can even mix the results. So I put a drop down where you can choose which ranking algorithm you want. I could probably add in a third algorithm as well!

It's very exciting. There is probably more stuff I can tweak but it seems to produce very good results.

## Read More

* [The Page Rank Citation Algorithm: Bringing Order To The Web](http://ilpubs.stanford.edu:8090/422/1/1999-66.pdf)

# Appendix - A Lot Of Domains

This is going to be a lot of domains, a top-25 ranking based on which domain the PageRank biases towards. I'm not hyperlinking them, but sample a few with copy&paste. They are mostly pretty interesting. 

## memex.marginalia.nu

The current seed

search.marginalia.nu
twtxt.xyz
wiki.xxiivv.com
www.loper-os.org
lee-phillips.org
memex.marginalia.nu
www.lord-enki.net
jim.rees.org
www.ranprieur.com
ranprieur.com
john-edwin-tobey.org
tilde.town
www.ii.com
equinox.eulerroom.com
cyborgtrees.com
lobste.rs
www.teddydd.me
collapseos.org
0xff.nu
antoine.studio
parkimminent.com
jitterbug.cc
www.awalvie.me
www.lambdacreate.com
desert.glass
mineralexistence.com
milofultz.com
ameyama.com
nchrs.xyz
ftrv.se
www.wileywiggins.com
www.leonrische.me
forum.camendesign.com
nilfm.cc
terra.finzdani.net
kokorobot.ca
www.tinybrain.fans
void.cc
akkartik.name
100r.co
sentiers.media
llllllll.co
www.paritybit.ca
sr.ht
eli.li
usesthis.com
marktarver.com
mvdstandard.net
blmayer.dev
dulap.xyz

## stpeter.im

Let's try someone who is more into the humanities.

monadnock.net
coccinella.im
www.coccinella.im
kingsmountain.com
metajack.im
anglosphere.com
www.kingsmountain.com
test.ralphm.net
ralphm.net
badd10de.dev
xmpp.org
memex.marginalia.nu
copyfree.org
etwof.com
chrismatthewsciabarra.com
www.chrismatthewsciabarra.com
www.igniterealtime.org
www.xmcl.org
www.jxplorer.org
search.marginalia.nu
www.bitlbee.org
perfidy.org
www.gracion.com
stpeter.im
www.ircap.es
www.ircap.net
www.ircap.com
dismail.de
wiki.mcabber.com
www.knowtraffic.com
www.rage.net
fsci.in
trypticon.org
www.riseofthewest.net
www.riseofthewest.com
fsci.org.in
www.planethofmann.com
www.badpopcorn.com
muquit.com
www.muquit.com
git.disroot.org
www.hackint.org
www.skills-1st.co.uk
glyph.twistedmatrix.com
www.thenewoil.xyz
leechcraft.org
anarchobook.club
ripple.ryanfugger.com
swisslinux.org
mikaela.info

## lobste.rs

These results are pretty similar to the MEMEX bunch, but with a bigger slant toward the technical I feel. Most of these people have a github link on their page. 

siskam.link
brandonanzaldi.com
neros.dev
matthil.de
www.gibney.org
www.possiblerust.com
kevinmahoney.co.uk
werat.dev
coq.io
64k.space
tomasino.org
axelsvensson.com
call-with-current-continuation.org
secretchronicles.org
adripofjavascript.com
alexwennerberg.com
nogweii.net
evaryont.me
reykfloeter.com
www.chrisdeluca.me
hauleth.dev
mkws.sh
danilafe.com
knezevic.ch
mort.coffee
writepermission.com
danso.ca
chown.me
syuneci.am
feed.junglecoder.com
magit.vc
antranigv.am
nathan.run
barnacl.es
soap.coffee
www.craigstuntz.com
pzel.name
eloydegen.com
robertodip.com
vincentp.me
vfoley.xyz
www.uraimo.com
creativegood.com
stratus3d.com
shitpost.plover.com
forums.foundationdb.org
hristos.co
hristos.lol
julienblanchard.com
euandre.org

## www.xfree86.org

Next up is an older site, and the results seem to reflect the change in seed quite well. Not all of them are old, but the *feel* is definitely not the same as the previous ones.

x-tt.osdn.jp
www.tjansen.de
www.blueeyedos.com
asic-linux.com.mx
checkinstall.izto.org
hobbes.nmsu.edu
www.stevengould.org
greenfly.org
www.parts-unknown.com
www.afterstep.org
lagarcavilla.org
brltty.app
aput.net
openmap-java.org
www.splode.com
links.twibright.com
www.dolbeau.name
www.dbsoft.org
dbsoft.org
www.sanpei.org
www.dubbele.com
www.sgtwilko.f9.co.uk
www.anti-particle.com
www.climatemodeling.org
www.sealiesoftware.com
sealiesoftware.com
openbsdsupport.org
www.momonga-linux.org
www.varlena.com
www.semislug.mi.org
www.dcc-jpl.com
www.tfug.org
www.usermode.org
www.mewburn.net
www.herdsoft.com
xfree86.org
www.xfree86.org
www.tinmith.net
tfug.org
james.hamsterrepublic.com
www.dummzeuch.de
arcgraph.de
www.fluxbox.org
www.treblig.org
josephpetitti.com
www.lugo.de
fluxbox.org
petitti.org
shawnhargreaves.com
ml.42.org

## xroads.virginia.edu

Old academic website related to American history.

www.sherwoodforest.org
www.expo98.msu.edu
www.trevanian.com
www.lachaisefoundation.org
www.toysrbob.com
darianworden.com
twain.lib.virginia.edu
dubsarhouse.com
www.carterfamilyfold.org
essays.quotidiana.org
va400.org
webpage.pace.edu
www.wyomingtalesandtrails.com
wyomingtalesandtrails.com
bbll.com
graybrechin.net
genealogy.ztlcox.com
www.bbll.com
www.graybrechin.net
www.thomasgenweb.com
thomasgenweb.com
www.granburydepot.org
www.northbankfred.com
www.melville.org
www.stratalum.org
mtmen.org
www.mtmen.org
onter.net
www.tommymarkham.com
www.robert-e-howard.org
www.straw.com
www.foucault.de
www.antonart.com
www.footguard.org
www.taiwanfirstnations.org
jmisc.net
www.jmisc.net
www.thegospelarmy.com
jimlong.com
pixbygeorge.info
www.boskydellnatives.com
www.imagesjournal.com
www.onter.net
silentsaregolden.com
imagesjournal.com
www.frozentrail.org
www.pocahontas.morenus.org
vinnieream.com
www.historyinreview.org
www.sandg-anime-reviews.net

## www.subgenius.com

www.quiveringbrain.com
revbeergoggles.com
www.seesharppress.com
www.vishalpatel.com
www.revbeergoggles.com
seesharppress.com
www.digital-church.com
lycanon.org
www.lycanon.org
all-electric.com
www.wd8das.net
fictionliberationfront.net
www.fictionliberationfront.net
www.radicalartistfoundation.de
cca.org
cyberpsychos.netonecom.net
www.stylexohio.com
StylexOhio.com
www.theleader.org
theleader.org
www.annexed.net
principiadiscordia.com
www.evil.com
www.the-philosophers-stone.com
the-philosophers-stone.com
www.hackersdictionary.com
kernsholler.net
www.kernsholler.net
www.booze-bibbing-order-of-bacchus.com
www.westley.org
www.bigmeathammer.com
www.littlefyodor.com
www.isotopecomics.com
sacred-texts.com
www.tarsierjungle.net
www.monkeyfilter.com
www.slackware.com
www.nick-andrew.net
www.eidos.org
www.templeofdin.co.uk
saintstupid.com
www.saintstupid.com
www.rapidpacket.com
www.mishkan.com
www.consortiumofgenius.com
www.xenu-directory.net
www.cuke-annex.com
www.nihilists.net
nihilists.net
madmartian.com


