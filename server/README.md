# openldap-server

This container runs an OpenLDAP server instance. It can be configured as a
standalone server, or joined to other instances with the same domain
suffix and multi-provider synchronization.

The LDAP database schema should be compliant with RFC2307.

## Environment variables

* `LDAP_ADMUSER`, default `admin`. Name of the initial member of `domain admins`
* `LDAP_ADMPASS`, default `secret`. Password of LDAP_ADMUSER
* `LDAP_SVCUSER`, default `ldapservice`. LDAP browse-only credentials
* `LDAP_SVCPASS`, default `pass`. Password of LDAP_SVCUSER
* `LDAP_DOMAIN`, default `nethserver.test`. It must match the DN suffix
  (e.g. `dc=nethserver,dc=test`)
* `LDAP_SUFFIX`, default `dc=nethserver,dc=test`. See LDAP_DOMAIN too.
* `LDAP_PORT`, TCP port number
* `LDAP_IPADDR`, server IP address (127.0.0.1 and Unix Domain socket are
  always added to this too)
* `LDAP_SERVERID`, a unique positive integer required to identify the
  server among others of the same domain
* `LDAP_DEBUGLEVEL`, slapd debug-level (see `slapd` manpage for info).
* `LDAP_LOGLEVEL`, slapd log level (see `slapd` manpage for info).
  Used to set log file verbosity, for debug purposes.

## Logs

The server sends log messages to the system log. Mount `/dev/log` inside
the container to write to the host syslog (i.e.
`--volume=/dev/log:/dev/log`). The verbosity is configured by
`olcLogLevel` (see `slapd-config` manpage). To change it on a running
`openldap1` container execute a command like:

    ldapmodify <<'EOF'
    dn: cn=config
    changetype: modify
    replace: olcLogLevel
    olcLogLevel: config stats sync
    EOF

For debug purposes logging to stderr is more performant. Increase stderr
verbosity with `LDAP_DEBUGLEVEL` when the container is created.

## Storage

The container runs as `ldap` user. All data is written under
`/var/lib/openldap`: mount it as a persistent volume to preserve the
database over the time, after executing different commands.

The initial volume must be empty to receive default volume contents from
the container image, and provision the LDAP tree with default users and
groups.

As alternative, mount a volume containing the LDAP DB dump file
`dump-mdb0.ldif`: the initial LDAP tree is then loaded from it.

## Commands

The container entrypoint starts `slapd` if no arguments are specified.
Otherwise the arguments are assumed to be a command and are exec()'d.

Commands to run when slapd is stopped:

* `new-domain`: initializes a new domain database with single server
  configuration. If the `dump-mdb0.ldif` file exists, loads it otherwise
  generate users and groups from the internal .ldif template file.
* `join-domain SRVURLs`: contact other servers at _SRVURLs_ and add this
  server to the existing domain.
* `leave-domain`: contact other (known) domain servers and tell them to
  remove this server from the domain.
* `load-dumpfiles`: restore the LDAP database from LDIF dump files:
  `dump-config.ldif`, `dump-mdb0.ldif`. Those files must exist and they
  must be valid LDIF dump files. Only a single-provider domain backup can
  be restored. Do not restore a backup if other providers of the same
  domain are still alive!

Other commands:
* `sh`: start a shell. The image provides OpenLDAP client binaries, like
  `ldapsearch`
* `remove-server SERVERID`: this command forcibly cleans up the local
  configuration DB, removing olcServerID and olcSyncrepl attributes
  referencing the given SERVERID.  While SERVERID is expected to be
  already destroyed, the local slapd server must be running. Applied
  changes are propagated to other servers with syncrepl as usual.

# Run with Podman

Create a `./lenv` file with the following contents

    LDAP_SVCUSER=ldapservice
    LDAP_SVCPASS=pass
    LDAP_DOMAIN=dom.test
    LDAP_SUFFIX=dc=dom,dc=test
    LDAP_SERVERID=1
    LDAP_PORT=10389
    LDAP_IPADDR=10.5.4.1

Provision the domain

    podman run -ti --rm --env-file=./lenv --volume=data1:/var/lib/openldap:z ghcr.io/nethserver/openldap-server:latest new-domain

Start the service

    podman run -d --name openldap --replace --network=host --rm --env-file=./lenv --volume=data1:/var/lib/openldap:z ghcr.io/nethserver/openldap-server:latest

Enter the container

    podman exec -ti openldap ash
