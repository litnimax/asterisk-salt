# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

asterisk-configs:
  file.recurse:
    - name: /etc/asterisk
    - source: salt://asterisk/files/configs
    - replace: False
