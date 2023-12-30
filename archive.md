---
layout: default
title: Archivio
---

# Archivio

Visualizza tutti i post raggruppati per mese e anno.

{% assign postsByYearMonth = site.posts | group_by_exp: "post", "post.date | date: '%B %Y'" %}
{% for yearMonth in postsByYearMonth %}
  <h2>{{ yearMonth.name }}</h2>
  <ul>
    {% for post in yearMonth.items %}
      <li><a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endfor %}
  </ul>
{% endfor %}

<div class="container">
  <div class="row">
    <div class="col col-12">
      <div class="contaniner__inner animate">
        <div class="row">
          {% for post in site.posts %}
          
          <div class="article col col-4 col-d-6 col-t-12">
            <div class="article__inner">
              <div class="article__content">
          
                <h2 class="post-title"><a href="{{ post.url }}">{{ post.title }}</a></h2> 
                <span class="post-date"><time datetime="{{ post.date | date_to_xmlschema }}" class="post-date">{{ post.date | date_to_string }}</time></span>

                {% if post.tags.size >= 1 %}
                  {% for tag in post.tags %}
                  <span class="tag">{{ tag }}</span>
                  {% endfor %}
                {% endif %}

                <p class="article__excerpt">
                  {% if post.description %}{{ post.description }}{% else %}{{ post.content | strip_html | truncate: 120 }}{% endif
                  %}
                </p>

              </div>
            </div>
          </div>
          {% endfor %}
        </div>
      </div>
    </div>
  </div>
</div>