# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

{% for sounds in asterisk.sounds %}
{%- set filename = '/var/lib/asterisk/sounds/' ~ salt['file.basename'](sounds.url) %}
{{ 'asterisk-download-' ~ filename }}:
  file.managed:
    - name: {{ filename }}
    - source: {{ sounds.url }}
    - skip_verify: true
    - creates: {{ filename }}

{{ 'asterisk-extract-' ~ filename }}:
  archive.extracted:
    - name: /var/lib/asterisk/sounds/{{ sounds.subdir }}
    - source: {{ filename }}
    - enforce_toplevel: false
    - user: {{ asterisk.user }}
    - trim_output: 5
{% endfor %}
