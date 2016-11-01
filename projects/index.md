---
layout: projects
title: "Open-source activity"
date: 2016-11-01T00:54:00+03:00
modified:
tags: [github, open-source]
image:
  feature:
  teaser:
---

<img src="http://ghchart.rshah.org/{{ site.owner.github }}" alt="{{ site.owner.github }} Github chart" />

<div id="feed"></div>

<script language="javascript" >
  GitHubActivity.feed({
      username: "{{ site.owner.github }}",
      selector: "#feed",
      limit: 10 // optional
  });
</script>

<div class="tiles">
{% for post in site.categories.project %}
  {% include post-list.html %}
{% endfor %}
</div><!-- /.tiles -->