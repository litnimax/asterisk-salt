deploy-conf-files:
  file.recurse:
    - name: /etc/asterisk
    - source: salt://files/odoopbx/asterisk_etc/
