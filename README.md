# The Salt of Asterisk
Current list of features:
* Asterisk PBX installation management (installation & upgrade)
* Security service (like fail2ban)
* WEB CLI (using xterm.js)

## Installation
Requirements:
* salt-minion (the Agent)
* terminado & tornado_xstatic (for Asterisk WEB CLI)

```
pip3 install salt tornado-xstatic terminado
```

By default ```/srv/asterisk-salt``` is used as a project directory.
Due to a bug/feature of *[extension_modules](https://github.com/saltstack/salt/issues/57813)* configuration
option we have to specify the absolute path to extensions folder in minion config so if you
change the folder do not forget to change also *extension_modules* option.

```
cd /srv/
git clone https://github.com/litnimax/asterisk-salt.git
```

To run the Agent:

```
cd /srv/asterisk-salt
salt-minion -l info
```

## Configuration
Configuration options are set in 3 places (relative to /srv/asterisk-salt):

 * **Saltfile** - here path for salt utilities is set to current folder.
 * **minion** - only main settings are set here.
 * **miniond.d** - this folder contains multiple files each defining some options.

