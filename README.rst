--------------------
The Salt of Asterisk
--------------------

Current list of features:

* Asterisk PBX installation management (installation & upgrade)
* Security service (like fail2ban)
* WEB CLI (using xterm.js)

Installation
------------
Requirements:

* salt-minion (so called "the Agent").
* Asterisk AMI library: panoramisk.
* ipset python bindings: ipsetpy.
* terminado & tornado_xstatic (for Asterisk WEB CLI).

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

    salt-call state.apply asterisk

And finally install the Salt minion startup service file and start it:

.. code:: sh

    salt-call state.apply agent

At this point you will have Asterisk and Salt minion up and running.

You can check the logs to see if everything is file:

.. code:: sh

    journalctl -u asterisk-agent

You can stop the Agent and run it in debug mode from the controlling terminal:

.. code:: sh

    systemctl stop asterisk-agent
    salt-minion -l debug


Configuration
-------------
Configuration is located in ``/etc/salt/minion``. Adjust it for your own environment.

Contacts and issues
-------------------
Please create new issues to get in contact.
