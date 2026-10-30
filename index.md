---
title: Making no sense.
permalink: "/"
layout: home
excerpt: "Notes on software, open source, and the ideas in between."
---

{% assign latest_post = site.posts | first %}
<section class="home-hero" aria-labelledby="home-title">
  <div class="home-intro">
    <p class="eyebrow">Timur Safin · Personal blog</p>
    <h1 id="home-title">Making <em>no sense.</em></h1>
    <p class="home-lead">Notes on software, open source, and the ideas in between.</p>
    <div class="home-actions">
      <a class="btn" href="{{ '/blog/' | relative_url }}">Read the articles <span aria-hidden="true">→</span></a>
      <a class="home-secondary" href="{{ '/resume/' | relative_url }}">About Timur</a>
    </div>
  </div>
  <a class="home-latest" href="{{ latest_post.url | relative_url }}">
    <div class="home-latest-image">
      {% if latest_post.image.teaser %}<img src="{{ latest_post.image.teaser | prepend: '/images/' | relative_url }}" alt="" itemprop="image">
      {% elsif latest_post.thumbnail %}<img src="{{ latest_post.thumbnail | relative_url }}" alt="" itemprop="image">
      {% else %}<img src="{{ site.teaser | prepend: '/images/' | relative_url }}" alt="" itemprop="image">{% endif %}
    </div>
    <div class="home-latest-content">
      <div class="home-latest-meta">
        <span>Latest note</span>
        <time datetime="{{ latest_post.date | date: '%Y-%m-%d' }}">{{ latest_post.date | date: "%b %d, %Y" }}</time>
      </div>
      <h2>{{ latest_post.title }}</h2>
      <span class="home-read-more">Read the story <span aria-hidden="true">↗</span></span>
    </div>
  </a>
</section>

<section class="posts-section" aria-labelledby="latest-posts-title">
  <header class="section-heading">
    <div>
      <p class="eyebrow">From the archive</p>
      <h2 id="latest-posts-title">Latest notes</h2>
    </div>
    <a class="archive-link" href="{{ '/blog/' | relative_url }}">View all articles <span aria-hidden="true">↗</span></a>
  </header>
  <div class="tiles">
  {% for post in site.posts offset: 1 limit: 6 %}
    {% include post-grid.html %}
  {% endfor %}
  </div>
</section>
