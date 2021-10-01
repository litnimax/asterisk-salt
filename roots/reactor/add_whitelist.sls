{% set ip = data['post'].get('ip')  %}

{% if data['headers'].get('X-Auth-Token') == opts['webhook_auth_token'] %}
verbose:
  local.log.info:
    - tgt: asterisk
    - args:
      - message: "API WHITELIST ADD IP: {{ ip }}"

setname_entries:
  local.ipset.add:
    - tgt: asterisk
    - args:
      - setname: whitelist
      - entry: {{ ip }}
      - comment: Added from webhook
{% else %}
verbose:
  local.log.warning:
    - tgt: asterisk
    - args:
      - message: "WEBHOOK BAD AUTH TOKEN"
{% endif %}

