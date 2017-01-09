===================
letsencrypt-formula
===================

A Salt formula to set up and configure Dehydrated for generating SSL certificates with Let's Encrypt.


Formula Dependencies
====================

The formula should run on most all standard \*nix environments. Dehydrated requires the following:

* bash
* curl
* diff
* grep
* mktemp
* openssl
* sed

Some deployment hooks have further dependencies.

Available states
================

.. contents::
    :local:

``letsencrypt``
---------------

Installs and configures Dehydrated.


Configuration
=============

Configuration is done via **Pillars**. A complete example can be found `here <pillar.example>`_.

Base
-------------------

At minimum, the following configuration is recommended:

.. code:: yaml

  letsencrypt:
    domains:
      domain1.example.com:
        alternatives:
          - domain1-01.example.com
          - domain1-02.example.com
      domain2.example.com:
      domain3.example.com:
    config:
      CA: https://acme-v01.api.letsencrypt.org/directory
      CONTACT_EMAIL: systems@example.com

Notice that the values under ``config`` match the values in the Dehydrated config file:
https://github.com/lukas2511/dehydrated/blob/master/docs/examples/config.

Account
-------------------

If configured, this formula will manage Dehydrated accounts. Otherwise accounts are registered
on first run and stored on the minion.

The accounts are stored by Dehydrated in the ``accounts`` directory using the base64 encoded string of the CA config parameter.

To have the formula manage the account for the production CA, define the following in your Pillar:

.. code:: yaml

  letsencrypt:
    accounts:
      aHR0cHM6Ly9hY21lLXYwMS5hcGkubGV0c2VuY3J5cHQub3JnL2RpcmVjdG9yeQo:
        registration: |
          {
            "id": 1234567,
            "key": {
              "kty": "RSA",
              "n": "...",
              "e": "..."
            },
            "contact": [
              "mailto:systems@example.com"
            ],
            "agreement": "https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf",
            "initialIp": "1.2.3.4",
            "createdAt": "2017-01-08T03:29:50.745138932Z",
            "Status": "valid"
          }
        key: |
          -----BEGIN RSA PRIVATE KEY-----
          MIIJKAIBAAKCA...
          -----END RSA PRIVATE KEY-----


Domains
-------------------

The ``domains`` configuration section allows for the declaration of domains to manage both the Dehydrated ``domains.txt`` file
and each individual certificate's ``config`` file.

Notice that the values under ``config`` match the values in the Dehydrated per-certificate config file:
https://github.com/lukas2511/dehydrated/blob/master/docs/per-certificate-config.md.

Additionally, the named ``hook`` can be specified per domain, more on hooks later.

.. code:: yaml

  letsencrypt:
    domains:
      domain1.example.com:
        config:
          KEYSIZE: 2048
        hook: hook1
        alternatives:
          - domain1-01.example.com
          - domain1-02.example.com
          - domain1-03.example.com
      domain2.example.com:
        alternatives:
          - domain3.example.com
      domain4.example.com:
      domain5.example.com:

*Note: all domains must be defined as a dictionary even if they do not have further configuration.*

Hooks
-------------------

Hooks allow for further control over the domain validation process. Typically they are used to automate the ``dns-01`` challenge type.

Hooks are named by their dictionary key which allows for an unlimited number of configured hooks of
similar or differing types for use in all or just some domains.

Hooks are defined in this format:

.. code:: yaml

  letsencrypt:
    hooks:
      hook1:
        type: executable
        ...
      hook2:
        type: dnsmadeeasy
        ...
      myotherhook1:
        type: dnsmadeeasy
        ...

Default Hook
~~~~~~~~~~~~

The default hook for all domains is defined like this:

.. code:: yaml

  letsencrypt:
    hook: hook1

Per-Domain Hooks
~~~~~~~~~~~~~~~~

Hooks can configured for just some domains like this:

.. code:: yaml

  letsencrypt:
    domains:
      domain1.example.com:
        hook: hook1
      domain2.example.com:
        hook: myotherhook1

Hook Types
~~~~~~~~~~

The hooks currently provided are:

``executable``
~~~~~~~~~~~~~~

The executable hook allows for the execution of an arbitrary file. This directly manages the Dehydrated ``HOOK`` config value.

Typically this is a BASH executable managed via Salt outside of the ``letsencrypt`` formula. A sample hook can be found here:
https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh.

An ``executable`` hook is defined like this:

.. code:: yaml

  letsencrypt:
    hooks:
      myhook:
        type: executable
        path: /some/path/hook.sh

``dnsmadeeasy``
~~~~~~~~~~~~~~~

Provides and configures the `dnsmadeeasy <https://github.com/alisade/letsencrypt-dnsmadeeasy-hook>`_ hook. Requires ``python3`` under ``/usr/bin/python3`` and ``git``.

A ``dnsmadeeasy`` hook is defined like this:

.. code:: yaml

  letsencrypt:
    hooks:
      myhook:
        type: dnsmadeeasy
        key: 'your api key'
        secret: 'you api secret key'

Limitations
=============

* Paths are fixed
    **/etc/dehydrated**
      configuration, accounts, certificates, hooks
    **/usr/local/bin/dehydrated**
      dehydrated executable
* Limited number of hooks provided
* Does not currently execute Dehydrated
* Probably more...
