change-port:
  file.line:
    - name: /etc/ssh/sshd_config
    - match: Port 22
    - content: Port 30022
    - mode: replace

sshd:
  service.running:
    - reload: True
    - watch:
      - file: change-port

