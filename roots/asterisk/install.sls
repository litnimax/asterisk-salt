# -*- coding: utf-8 -*-
# vim: ft=yaml
---
{% from "asterisk/map.jinja" import asterisk with context %}

asterisk-user:
  user.present:
    - name: {{ asterisk.user }}
    - usergroup: True
    - shell: /bin/bash
    - home: /var/lib/asterisk

asterisk-pkgs:
  pkg.installed:
    - pkgs: {% set pkgs_list = asterisk.pkgs.split() %} {{ pkgs_list }}

asterisk-git:
  git.latest:
    - name: https://github.com/asterisk/asterisk.git
    - branch: {{ asterisk.rev }}
    - rev: {{ asterisk.rev }}
    - depth: 1
    - fetch_tags: False
    - target: {{ asterisk.src_dir }}
    - creates: {{ asterisk.src_dir }}

asterisk-install:
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
      - WGET_EXTRA_ARGS="-q" make install:
        - creates: /usr/sbin/asterisk
      - chown -R {{ asterisk.user }} /var/*/asterisk
    - cwd: {{ asterisk.src_dir }}

asterisk-menuselect:
  cmd.run:
    - name: >
        menuselect/menuselect
        --enable {{ asterisk.menuselect_enable | join(" --enable ") }}
        --disable {{ asterisk.menuselect_disable | join(" --disable ") }}
    - cwd: {{ asterisk.src_dir }} 

asterisk-configs:
  file.recurse:
    - name: /etc/asterisk
    - source: salt://asterisk/etc
    - replace: False

asterisk-system:
  file.managed:
    - names:
      - /etc/logrotate.d/asterisk:
        - source: salt://asterisk/templates/asterisk.logrotate
      - /etc/systemd/system/asterisk.service:
        - source: salt://asterisk/templates/asterisk.service
    - template: jinja
    - context: {{ asterisk }}
    - backup: minion

{% if grains.virtual == "container" %}
asterisk-running:
  cmd.run:
    - name: /usr/sbin/asterisk -F
    - runas: {{ asterisk.user }}
    - unless: pidof asterisk
{% else %}
asterisk-running:
  service.running:
    - name: asterisk
    - enable: True
{% endif %}
