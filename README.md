# ns8-openldap

The `ns8-openldap` core module implements a multi-provider OpenLDAP
cluster. Both data and configuration are replicated among the cluster
nodes.  The user and group accounts are stored according to the RFC2307
schema.

## Domain admins

Members of the builtin group `domain admins` are granted a special
read-only access to the configuration database, that is necessary to
retrieve `olcRootPW` and configure (join) additional nodes.

They are also granted `manage` permissions on the full data set.

## Configure the module

The domain is usually managed through the cluster APIs. Consider the
following information as "low-level" implementation.

Create a new LDAP domain `dom.test`

    api-cli run module/openldap1/configure-module --data '{"provision":"new-domain","admuser":"admin","admpass":"secret","domain":"dom.test"}'

The *admuser* credentials are used to create an initial account in the
user database. The account is granted permission to join additional
servers to the domain.

Further OpenLDAP instances for the same `domain` must be joined in a
multi-provider cluster:

    api-cli run module/openldap2/configure-module --data '{"provision":"join-domain","admuser":"admin","admpass":"secret","domain":"dom.test"}'

The *admuser* credentials are now necessary to join the second node with the
first one.

## Debug and Log

The module sends slapd log messages to the syslog. The `LDAP_LOGLEVEL`
variable sets the initial syslog-level value of slapd when the `openldap`
container is created.  To alter the syslog-level value on a module that
has been already configured, run the following command instead:

    podman exec -i openldap ldapmodify <<EOF
    dn: cn=config
    changetype: modify
    replace: olcLogLevel
    olcLogLevel: config stats sync
    EOF

It is possible to run slapd with an increased debug level. Debug messages
are sent to stderr, which is forwarded to Systemd journal. Set
`LDAP_DEBUGLEVEL` environment variable and restart the `openldap` service.

    runagent sh -c 'echo LDAP_DEBUGLEVEL=255 >> environment'
    systemctl --user restart openldap

See also the server README.

## Users and group management APIs

Create group `mygroup1`

    api-cli run module/openldap1/add-group --data '{"group":"mygroup1","description":"My group","users":[]}'

Change the group description

    api-cli run module/openldap1/alter-group --data '{"group":"mygroup1","description":"My Group 1"}'

Create user `first.user` as member of `mygroup1`

    api-cli run module/openldap1/add-user --data '{"user":"first.user","display_name":"First User","password":"Nethesis,1234","groups":["mygroup1"]}'

Change First User's password

    api-cli run module/openldap1/alter-user --data '{"user":"first.user","password":"Neth,123"}'

## User management web portal

The `openldap` module provides a public web portal where LDAP users can
authenticate and change their passwords.

The module registers a Traefik path route, with the domain name as suffix.
For instance:

    https://<node FQDN>/users-admin/domain.test/

The backend of the module runs under the `api-moduled.service` Systemd
unit supervision. Refer also to `api-moduled` documentation, provided by
`ns8-core` repository.

API implementation code is under `imageroot/api-moduled/handlers/`, which
is mapped to an URL like

    https://<node FQDN>/users-admin/domain.test/api/

The `.json` files define the API input/output syntax validation, using the
JSON schema language. As such they can give an idea of request/response
payload structure.
