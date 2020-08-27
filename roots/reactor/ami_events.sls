{% if data.get('Event') in ['InvalidPassword', 'InvalidAccountID', 'ChallengeResponseFailed'] %}
ban_ip:
  caller.asterisk.ban_event:
    - args:
      - event: {{ data }}
{% endif %}
