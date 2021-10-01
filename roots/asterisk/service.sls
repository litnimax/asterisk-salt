# -*- coding: utf-8 -*-
# vim: ft=sls
---

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import asterisk with context %}

asterisk-user:
  user.present:
    - name: {{ asterisk.user }}
    - usergroup: True
    - shell: /bin/bash
    - home: /var/lib/asterisk

asterisk-directories:
  file.directory:
    - names:
      - /var/log/asterisk
      - /var/run/asterisk
      - /var/lib/asterisk
      - /var/spool/asterisk
    - user: {{ asterisk.user }}
    - recurse:
      - user

asterisk-service:
  file.managed:
    - names:
      - /etc/logrotate.d/asterisk:
        - source: salt://asterisk/files/asterisk.logrotate
      - /etc/systemd/system/asterisk.service:
        - source: salt://asterisk/files/asterisk.service
    - template: jinja
    - context: {{ asterisk }}
    - backup: minion

asterisk-running:
{% if "virtual_subtype" in grains %}
  cmd.run:
    - name: /usr/sbin/asterisk -F
    - runas: {{ asterisk.user }}
    - unless: pidof asterisk
{% else %}
  service.running:
    - name: asterisk
    - enable: True
{% endif %}
