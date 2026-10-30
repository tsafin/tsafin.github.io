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

<img class="projects-chart" src="https://ghchart.rshah.org/{{ site.owner.github }}" alt="{{ site.owner.github }} GitHub contribution chart" loading="lazy" />

<div id="feed"></div>

<script language="javascript" >
  GitHubActivity.feed({
      username: "{{ site.owner.github }}",
      selector: "#feed",
      limit: 10 // optional
  });
</script>

<div class="archive-list">
{% for post in site.categories.project %}
  {% include post-list.html %}
{% endfor %}
</div>