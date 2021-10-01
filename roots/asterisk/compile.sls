# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

asterisk-compile:
  cmd.run:
    - names:
      - ./contrib/scripts/get_mp3_source.sh:
        - creates: "{{ asterisk.src_dir }}/addons/mp3/mpg123.h"
      - ./configure {{ asterisk.configure_options }}:
        - creates: "{{ asterisk.src_dir }}/config.status"
      - make menuselect.makeopts:
        - creates: "{{ asterisk.src_dir }}/menuselect.makeopts"
      - make -j{{ grains.num_cpus }}:
        - creates: "{{ asterisk.src_dir }}/main/asterisk"
        - require:
          - cmd: asterisk-menuselect
    - cwd: {{ asterisk.src_dir }}

asterisk-menuselect:
  cmd.run:
    - name: >
        menuselect/menuselect
        --enable {{ asterisk.menuselect_enable | join(" --enable ") }}
        --disable {{ asterisk.menuselect_disable | join(" --disable ") }}
    - cwd: {{ asterisk.src_dir }}
