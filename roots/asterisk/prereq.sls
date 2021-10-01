# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

{% set pkg_list = asterisk.pkgs_basic.split() | union(asterisk.pkgs_build.split()) %}

asterisk-prereq:
  pkg.installed:
    - pkgs: {{ pkg_list }}
