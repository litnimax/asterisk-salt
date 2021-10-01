# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

asterisk-sources:
  git.latest:
    - name: https://github.com/asterisk/asterisk.git
    - branch: {{ asterisk.rev }}
    - rev: {{ asterisk.rev }}
    - depth: 1
    - target: {{ asterisk.src_dir }}
    {% if asterisk.force_update  %}
    - force_clone: True
    - force_checkout: True
    - force_reset: True
    {% else %}
    - creates: {{ asterisk.src_dir }}/.git
    {% endif %}
