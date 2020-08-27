{% from "agent/map.jinja" import agent with context %}

agent-deps:
  pkg.installed:
    - pkgs: {{ agent.pkgs }}
  pip.installed:
    - pkgs: {{ agent.pip }}

agent-service:
  file:
    - managed
    - name: /etc/systemd/system/odoopbx-agent.service
    - source: salt://agent/agent.service
{% if grains.virtual != "container" %}
  service:
    - running
    - name: odoopbx-agent
    - enable: True
    - require:
      - pip: agent-deps
      - pkg: agent-deps
{% endif %}
