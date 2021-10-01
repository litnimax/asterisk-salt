--------------------
The Salt of Asterisk
--------------------

Current list of features:

* Asterisk PBX installation management (installation & upgrade)
* Security service (like fail2ban) with API to manage blacklisted / whitelisted IP addresses.
* WEB CLI (using xterm.js)

Installation
------------
Requirements:

* Python3 and python3-pip.
* salt-minion (so called "the Agent").
* Asterisk AMI library: panoramisk.
* iptables & ipset.
* ipset python bindings: ipsetpy.
* terminado & tornado_xstatic (for Asterisk WEB CLI).

Here is the installation script for fresh Ubuntu 20.04.

Install Python3 and pip:

.. code:: sh

    apt install python3-pip iptables ipset

Clone the repo to ``/etc/salt``:

.. code:: sh

    cd /etc/
    git clone https://github.com/litnimax/asterisk-salt.git salt


Install the python requirements:

.. code:: sh

    cd /etc/salt
    pip3 install -r requirements.txt

Install Asterisk (if required) or see ``/etc/salt/roots/asterisk/etc`` .conf files for example.

.. code:: sh

    salt-call -l info state.apply asterisk

And finally install the Salt minion startup service file and start it:

.. code:: sh

    salt-call -l info state.apply agent

At this point you will have Asterisk and Salt minion up and running.

You can check the logs to see if everything is file:

.. code:: sh

    journalctl -u asterisk-agent

You can stop the Agent and run it in debug mode from the controlling terminal:

.. code:: sh

    systemctl stop asterisk-agent
    salt-minion -l debug

Webhook configuration for API
-----------------------------
It is possible to integrate ipset lists management in a 3-rd party application using
Salt's network API configuration.

For this we have to also enable Salt master and Salt API processes and re-configure minion
to connect to local Salt master. Also do ``pip3 install cherrypy``.

See ``master`` configuration for defaults. Start ``salt-master`` and ``salt-api`` processes.

To make minion connect to the master remove ``master_type`` option from ``minion`` configuration file
and add there ``master: 127.0.0.1`` (and restart the minion).

Accept minion's key:

.. code:: sh

    salt-key -L
    salt-key -A

Then test the webhook:

.. code:: sh

    curl -k -X POST https://127.0.0.1:8000/hook/add_whitelist -d -H 'X-Auth-Token: 697adbdc8fe971d09ae4c2a3add7248859c870791' -d ip=1.2.3.4

To debug see master's event bus:

.. code:: sh

    salt-run state.event pretty=True


Configuration
-------------
Configuration is located in ``/etc/salt/minion``. Adjust it for your own environment.

Asterisk WEB console
--------------------
To be described...

Contacts and issues
-------------------
Please create new issues to get in contact.

