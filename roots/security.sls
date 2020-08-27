security-ipset-whitelist:
  ipset.set_present:
    - set_type: hash:net
    - name: whitelist
    - comment: True
    - counters: True


security-ipset-blacklist:
  ipset.set_present:
    - set_type: hash:net
    - name: blacklist
    - comment: True
    - counters: True
    - timeout: 3600

security-chan-voip:
  iptables.chain_present:
    - name: voip

security-ports-udp:
  iptables.insert:
    - position: 1
    - table: filter
    - family: ipv4
    - chain: INPUT
    - connstate: NEW
    - jump: voip
    - dports: 4569,5060
    - proto: udp
    - comment: iax,sip

security-ports-tcp:
  iptables.insert:
    - position: 1
    - table: filter
    - family: ipv4
    - chain: INPUT
    - connstate: NEW
    - jump: voip
    - dports: 80,443,5038,5039,5060,5061,8088,8089
    - proto: tcp
    - comment: www,manager,sip,http

securityp-match-whitelist:
  iptables.append:
    - chain: voip
    - match-set: whitelist src
    - jump: ACCEPT

security-match-blacklist:
  iptables.append:
    - chain: voip
    - match-set: blacklist src
    - jump: DROP

{% for agent in ['VaxSIPUserAgent', 'friendly-scanner', 'sipvicious', 'sipcli'] %}
security-scanner-{{ agent }}:
  iptables.append:
    - chain: voip
    - match: string
    - string: {{ agent }}
    - algo: bm
    - jump: DROP
{% endfor %}
