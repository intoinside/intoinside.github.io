---
layout: default
title: Archivio
---

# Archive

<div class="container">
    <div class="col col-12">
      <div class="contaniner__inner animate">
          {% for post in site.posts %}
          
            <div class="article__inner">
              <div class="article__content">
          
                <h2 class="post-title"><a href="{{ post.url }}">{{ post.title }}</a></h2>
                <div>
                <span><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_string }}</time></span>

                {% if post.tags.size >= 1 %}
                  {% for tag in post.tags %}
                  <span class="tag">{{ tag }}</span>
                  {% endfor %}
                {% endif %}
</div>
                <p class="article__excerpt">
                  {% if post.description %}{{ post.description }}{% else %}{{ post.content | strip_html | truncate: 120 }}{% endif
                  %}
                </p>

            </div>
          </div>
          {% endfor %}
      </div>
  </div>
</div>