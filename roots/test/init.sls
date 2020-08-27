{% set odoo = salt['pillar.get']('odoo') %}
{% do odoo.update(salt['grains.get']('odoo', {})) %}
{% set agent = salt['pillar.get']('agent') %}
{% do agent.update(salt['grains.get']('agent', {})) %}

test0:
  test.nop:
    - name: {{ odoo.srcdir }}

test1:
  file.managed:
    - name: /tmp/x.conf
    - source: salt://odoo/templates/odoo.service
    - template: jinja
    - context:
      odoo: {{ odoo }}

#include:
#  - .someconf
