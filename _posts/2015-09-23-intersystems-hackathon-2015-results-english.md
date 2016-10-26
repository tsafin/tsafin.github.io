---
layout: article
title:  InterSystems hackathon 2015 results
date:   2015-09-23 15:49:24 +0300
categories: hackathon
comments: true
blogger_orig_url: http://writeimagejournal.com/?p=1912
---

<blockquote><em>[Русская версия статьи изначально опубликована на <a href="http://habrahabr.ru/company/intersystems/blog/267459/" target="_blank">Хабре здесь</a>]</em></blockquote>

We have never arranged hackathon before, and none of us has even participated in such events. But if we bring ~50 of experienced COS developers to the same location for multi days training then why not try to apply their expertise for our good? Divide to teams, ask for ideas, and make them code some crazy projects in 1 day of hacking. _[Well a little bit less than 1 day as we have found actually, but still idea is the same]_

We are newbies in hackathon organization, so we asked for the external help – we have contacted Grigory Petrov (now technical evangelist of Voximplant, and former evangelist of Digital October center where he arranged several hackathon and similar events). He was willing to help, but we have discovered the harder way that he has to be in PyCon 2015 the same days we arrange Russian InterSystems School. Sigh. In any case, after long discussion with Grigory we have got clear understanding of all possible scenarios, of steps we need to proceed before hackathon, during, what to do, when and in which sequence. We were mentally ready for it.

InterSystems Fall School is usually 2-3 days long event. This year we were planning to start with almost 2 days of technical training and exercises (where most of training were doing various operations over the same dataset – database of sql.ru/cache posts). And after those 2 days participant supposed to be well prepared to use modern practices (using Angular for the client development, DeepSee and iKnow for analytics, and such).

At around of 17:00 of 2<sup>nd</sup> day we started hackathon: after brief introduction of rules and planned schedule, we started initial project teams assembly. The plan was  – get all possible ideas for projects from all relevant sources (i.e. our Russian University grants suggested projects, or suggested extension ideas to some already existing GitHub projects), start to discuss them and then choice project from the list, or any other relevant idea (which might be influenced by the list of suggested ideas).

<!-- <a href="/assets/team-list.jpg"><img class="size-medium wp-image-1917 aligncenter" src="/assets/team-list-170x300.jpg" alt="team-list" width="170" height="300" /></a> -->

<div class="card">
    <div class="card-image">
      <img src="/assets/team-list.jpg" alt="team-list" width="170" height="300">
    </div>
</div>

<!-- ![team-list](/assets/team-list.jpg) -->

If we review now all projects, which started, and categorize them by their sources, then we see that only small fraction were using topics of the suggested list. Most winners were developing their own idea.

Here is the list of projects at the start:
<table>
<tbody>
<tr>
<td width="414">1.       Atom plugin;</td>
<td width="736">Suggested development of existing project</td>
</tr>
<tr>
<td width="414">2.       CPM web site;</td>
<td width="736">Suggested development of existing project</td>
</tr>
<tr>
<td width="414">3.       Geo-spatial indices</td>
<td width="736">Suggested but new</td>
</tr>
<tr>
<td width="414">4.       Caché &lt;&gt; JS projection</td>
<td width="736">Brand new</td>
</tr>
<tr>
<td width="414">5.       Arduino connect</td>
<td width="736">Suggested but new</td>
</tr>
<tr>
<td width="414">6.       Call diagram</td>
<td width="736">Brand new</td>
</tr>
<tr>
<td width="414">7.       B*-Tree map</td>
<td width="736">Brand new</td>
</tr>
</tbody>
</table>
We have proceeded a couple of intermediate stops where we have reviewed project advancement (i.e. at around 22:00 the 1<sup>st</sup> day, and at 11:00 the next day). And we stopped development at the 13:00 the 2<sup>nd</sup> day (due to logistics constraints), and not as if it would be spanning whole day hacking – the 17:00 the 2<sup>nd</sup> day. i.e. teams have only 20 hours for development, but apparently it was not a big deal for those who prepared well enough.

Each team had 5-10 minutes for presentation, and then ISC SEs decided which teams are winners. We have touch problem to choose – there were 4 brilliant works, each of them in other circumstances would be considered a winner. But we decided that Nikita Savchenko/Anton Gnibeda work this day was the best. Just because of astonishing development speed (only 1 day since the project inception) and the shown quality and achieved results.

<!-- 
<a href="/assets/hackathon-1.jpg"><img class="alignnone wp-image-1920" src="/assets/hackathon-1-300x265.jpg" alt="hackathon-1" width="159" height="142" /></a> <a href="/assets/hackathon-2.jpg"><img class="alignnone wp-image-1918" src="/assets/hackathon-2-300x214.jpg" alt="hackathon-2" width="195" height="142" /></a> <a href="/assets/hackathon-3.jpg"><img class="alignnone wp-image-1919" src="/assets/hackathon-3-300x254.jpg" alt="hackathon-3" width="166" height="142" /></a> -->
![hackathon-1](/assets/hackathon-1.jpg)![hackathon-2](/assets/hackathon-2.jpg)![hackathon-3](/assets/hackathon-3.jpg)

Here are more details about projects winners:
<h1>1<sup>st</sup> place</h1>
Nikita Svchenko and Anton Gnibeda are stars of our local community. They both participated in many outstanding projects, e.g
<ul>
	<li><a href="https://github.com/ZitRos">Nikita @ZitRos Savchenko</a>: LightPivotTable in <a href="https://github.com/ZitRos/LightPivotTable">DeepSee Mobile</a>, <a href="https://github.com/ZitRos/CacheUMLExplorer">CacheUMLExplorer</a>, <a href="https://github.com/intersystems-ru/webterminal">WebTerminal</a>, <a href="https://github.com/ZitRos/globalsDB-Admin-NodeJS">GlobalsDB Admin</a>, etc</li>
	<li><a href="https://github.com/gnibeda">Anton @gnibeda Gnibeda</a>: <a href="https://github.com/intersystems-ru/DeepSeeWeb">DeepSee Web</a>, <a href="https://github.com/intersystems-ru/DeepSeeMobile">DeepSee Mobile</a></li>
</ul>
Although Nikita, Anton and Irina are all living in Kiev nowadays, but they usually not working on the same project at the same time, and this school was a rare chance for them to work together. But when they decided to form the team we (organizers) were tending to break a team and rebalance to others because other teams will be lacking of frontend skills we need elsewhere. However, at the end we decided to just see where this star team could go given opportunity and chance. [That was correct decision as we see today]

This project was not developing some precooked project as many other were doing. They have developed idea at the start of 2<sup>nd</sup> day of school, and then started coding immediately.
<h2>JavaScript Object Data Model — JavaScript object projection from Caché</h2>
<table>
<tbody>
<tr>
<td width="321">Team:</td>
<td width="1017"><a href="https://d.docs.live.net/32e0f479b4a6efd5/isc/school-2015/hackathon-isc-schoool-2015.docx">Nikita @ZitRos Savchenko</a>, <a href="https://github.com/gnibeda">Anton @gnibeda Gnibeda</a>, <a href="https://github.com/Gra-ach">Irene @Gra-ach Mikhailova</a></td>
</tr>
<tr>
<td width="321">GitHub repo:</td>
<td width="1017"><a href="https://github.com/ZitRos/cjs">https://github.com/ZitRos/cjs</a></td>
</tr>
</tbody>
</table>
There are 2 parts in this projects: server COS and client JavaScript. Server-side is simple REST data-points which allow get access to methods/properties of a classes. Client-side uses dirty JavaScript magic for extending client-side objects with the list of available server-side methods/properties. Which simplify debugging in the debugger

<!-- <a href="/assets/cjs-in-browser.jpg"><img class="wp-image-1914 aligncenter" src="/assets/cjs-in-browser-300x165.jpg" alt="cjs-in-browser" width="531" height="301" /></a> -->
![cjs-in-browser](/assets/cjs-in-browser.jpg)

The beauty of this API design – it uses “proper”, modern paradigms in the JavaScript part, i.e. async calls and cascading where possible.
```JavaScript
cjs.connector.connect("http://172.16.2.172:57776/", "Samples", ["School2015"], function (cache) {
// creating a new object
 var p = new cache.School2015.Participant();
 p.Name = "Anton";
 p.Surname = "Gnibeda";
 p.$save(function(obj) {
   console.log("Participant with name " + obj.name + " saved!");
 });
// executing instance method
 cache.School2015.Group.openById(1, function (group) {
   group.PrintInfo(function (res) {
     console.log(res);
   });
 });
// executing linq-like queries
 cache.School2015.Participant
   .query()
   .where("Carma &lt; 100 OR Carma &gt; 140")
   .where("$id &gt; 10")
   .orderByDesc("Carma")
   .orderBy("Name")
   .exec(function(res) {
     console.table(res);
   });
 });

<h1>2<sup>nd</sup> place</h1>

<em>As I already mentioned </em><a href="http://writeimagejournal.com/?p=1902"><em>as a preparation step to hackathon</em></a><em> we have formed a list of “interesting” task, which might be approached during hackathon. This was collected of Russian grants backlog and current GitHub projects backlog, with few additions of ideas from ISC employees.</em>

And it was a good surprise for us when 1 of topics from grant backlog list was selected as a hackathon projects – geo indices.

<h2>Geospatial — spatial indices in Caché</h2>

<table>
<tbody>
<tr>
<td width="321">Team:</td>
<td width="1017"><a href="https://github.com/ARechitsky">Andrey @Arechitsky Rechitsly</a>, <a href="https://github.com/adaptun">Alexander @adaptun Koblov</a>, <a href="https://github.com/APogrebnikov">Alexander @Apogrebnikov Pogrebnikov</a></td>
</tr>
<tr>
<td width="321">GitHub repo:</td>
<td width="1017"><a href="https://github.com/intersystems-ru/spatialindex">https://github.com/intersystems-ru/spatialindex</a></td>
</tr>
</tbody>
</table>

This was a long-standing request – we wanted that someone would implement support of geo spatial indices in Caché. There was no single reason why it could not be done eventually, given enough of expertise and opportunity. This hackathon was a good chance, because this team formed was overwhelmed with mathematics skills and COS expertise.

Thanks to this project now we have custom indices which internally use quad-trees for given set of geo pairs. Also authors have demonstrated simple Angular application, which visualizes quick search for the given box on map, and this search takes fractions of seconds even for the multiple millions in dataset.

In essence adding of such geospatial indices could be done this way:
<ol>
	<li>Add index for the pair of properties (longitude, latitude):</li>
</ol>
<pre>Index x1f on (Latitude,Longitude) As SpatialIndex.Index;</pre>
<ol start="2">
	<li>Search for the given box of coordinates</li>
</ol>
<pre>SELECT *
 FROM SpatialIndex.Test
 WHERE %ID %FIND search_index(x1F,'window','minx=56,miny=56,maxx=57,maxy=57')</pre>
<ol start="3">
	<li>Search for the given ellipse</li>
</ol>
<pre>SELECT *
 FROM SpatialIndex.Test
 WHERE  %ID %FIND search_index(x1F,'radius','x=55,y=55,radiusX=2,radiusY=2')
 and name %StartsWith 'Z'</pre>

This is only beginning of an implementation, obviously, and not in any case is pretending to be ISO 19125 compliant in this early development state. But that was an important 1<sup>st</sup> step, and is already usable in the COS projects

I am super excited about this particular project! It is not that polished as other winning projects, but could be influencing product in a long run…

<h1>3<sup>rd</sup> place</h1>

<em>We decided to give 3<sup>rd</sup> place to 2 brilliant projects: call diagram visualizer and global map visualizer.</em>

<em>And worth to note that both these projects were directly influenced by Nikita Savchecnko’ </em><a href="https://github.com/intersystems-ru/UMLExplorer"><em>UMLExplorer</em></a>
<h2>Callsmap —call diagram visualization</h2>
<table>
<tbody>
<tr>
<td width="320">Team:</td>
<td width="824"><a href="https://github.com/doublefint">Oleg @doublefint Dmitrovich</a>, Evgenia Litvin, <a href="https://github.com/TsvetkovAV">Alexander @TsvetkovAV Tsvetokov</a></td>
</tr>
<tr>
<td width="320">GitHub repo:</td>
<td width="824"><a href="https://github.com/intersystems-ru/callsmap">https://github.com/intersystems-ru/callsmap</a></td>
</tr>
</tbody>
</table>
Oleg Dmitrovich liked how UMLExplorer visualized class hierarchy, and he wanted to extend it with call diagram functionality. They parse classes themselves, extracting method and function names, and then want to show call graph somehow. But unfortunately the components used in the UMLExplorer was not scalable enough to handle so many classes as Oleg had in their development namespaces (several thousand of classes, with the corresponding number of call edges). Thus he had to find another JavaScript component which could handle their situation and eventually they ended up using <a href="https://github.com/anvaka/VivaGraphJS">Viva Graph</a>, which is <em>very fast</em>.

In some of their namespaces call diagram “galaxy” could be visualized this way:

<!-- <a href="/assets/cache-galaxy.png"><img class="wp-image-1913 aligncenter" src="/assets/cache-galaxy-300x252.png" alt="cache-galaxy" width="500" height="423" /></a> -->
![cache-galaxy](/assets/cache-galaxy.png)

Static picture does not show the whole beauty of a visualized diagram (which has nice animation effect in <a href="https://github.com/anvaka/VivaGraphJS">Viva Graph</a>, in real life this graph animation is really astonishing)

<h2>CacheBlocksExplorer — global tree and database map visualizer</h2>

<table>
<tbody>
<tr>
<td width="320">Team:</td>
<td width="717"><a href="https://github.com/daimor">Dmitry @daimor Maslennikov</a>, Olga Kazantseva</td>
</tr>
<tr>
<td width="320">GitHub repo:</td>
<td width="717"><a href="https://github.com/intersystems-ru/CacheBlocksExplorer">https://github.com/intersystems-ru/CacheBlocksExplorer</a></td>
</tr>
</tbody>
</table>

Yet another project, which has been created on UMLExplorer engine — is that global tree, and database map visualizer created by Dmitry Maslennikov. Actually he had working <em>globals b*-tree visualizer</em> even before hackathon started (as a side effect of one question he has been asked at the Vladivostock training he delivered before). But once he showed his project at the start of hackathon the consensus was that we all want database map just like in old school “Norton SpeedDisk”. So Dmitry has implemented just exactly that map in 1 night.

<!-- <a href="/assets/global-tree.png"><img class="alignnone wp-image-1916" src="/assets/global-tree-300x171.png" alt="global-tree" width="499" height="290" /></a> <a href="/assets/disk-map.png"><img class="alignnone wp-image-1915" src="/assets/disk-map-300x171.png" alt="disk-map" width="499" height="290" /></a> -->
![global-tree](/assets/global-tree.png)

Now, as a side effect of this project development we have 2 very valuable tools, which might be useful both for education and for performance analysis.

> _It will be one of my favorite tools, I guess._

<h1>Other noticeable projects</h1>

There were 3 more projects which got to the final pitching stage in various conditions. Most of them are long-standing projects, and will be probably mentioned later, once some notable development would happened and went online. Not today

Here are their repositories in any case:

<table>
<tbody>
<tr>
<td width="242">CPM</td>
<td width="682"><a href="https://github.com/intersystems-ru/CPM">https://github.com/intersystems-ru/CPM</a></td>
</tr>
<tr>
<td width="242">Atom COS Studio</td>
<td width="682"><a href="https://github.com/UGroup/Atom-COS-Studio">https://github.com/UGroup/Atom-COS-Studio</a></td>
</tr>
<tr>
<td width="242">Arduino Snippets</td>
<td width="682"><a href="https://github.com/intersystems-ru/ArduinoSnippets">https://github.com/intersystems-ru/ArduinoSnippets</a></td>
</tr>
</tbody>
</table>

<h1>Conclusion</h1>

Now, several days after the hackathon completion we might derive cold hearty conclusions, and should admit that this hackathon experiment was more than successful, and produced 4 brilliant projects which will be of much help to community and to the product in a longer run.

Ain’t it cool?

* [https://plus.google.com/+TimurSafin1/posts/AN2JcP9K2yx](https://plus.google.com/+TimurSafin1/posts/AN2JcP9K2yx)
* [https://plus.google.com/+TimurSafin1/posts/9BMJjFAqmxn](https://plus.google.com/+TimurSafin1/posts/9BMJjFAqmxn)
* [https://www.facebook.com/groups/mskiscmeetup/permalink/1056669757706535/](https://www.facebook.com/groups/mskiscmeetup/permalink/1056669757706535/)

