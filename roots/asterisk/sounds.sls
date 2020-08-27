/root/asterisk-extra-sounds-en-wav-current.tar.gz:
  file.managed:
    - skip_verify: True
    - source: https://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz

/usr/share/asterisk/sounds/en:
  archive.extracted:
   - clean: True
   - enforce_toplevel: False
   - require:
     - file: /root/asterisk-extra-sounds-en-wav-current.tar.gz
   - source: /root/asterisk-extra-sounds-en-wav-current.tar.gz

