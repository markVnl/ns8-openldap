#!/bin/ash

#
# Copyright (C) 2022 Nethesis S.r.l.
# http://www.nethesis.it - nethserver@nethesis.it
#
# This script is part of NethServer.
#
# NethServer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License,
# or any later version.
#
# NethServer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NethServer.  If not, see COPYING.
#

# shellcheck shell=dash disable=SC3001,SC3060

set -e # exit on error
set -a # export all variables

# Mandatory variables: the container must be created with the right values
LDAP_SERVERID=${LDAP_SERVERID:?}
LDAP_SUFFIX=${LDAP_SUFFIX:?}
LDAP_DOMAIN=${LDAP_DOMAIN:?}
LDAP_IPADDR=${LDAP_IPADDR:?}
LDAP_PORT=${LDAP_PORT:?}
LDAP_DEBUGLEVEL=${LDAP_DEBUGLEVEL:?}
LDAP_LOGLEVEL=${LDAP_LOGLEVEL:?}

# Define additional variables for our template files
tmpl_server_url="ldap://${LDAP_IPADDR}:${LDAP_PORT}"
# shellcheck disable=SC2034 # used by templates
tmpl_config_rid=$(( LDAP_SERVERID * 2 ))
# shellcheck disable=SC2034 # used by templates
tmpl_data_rid=$(( tmpl_config_rid + 1  ))
# shellcheck disable=SC2034 # used by templates
tmpl_domain_prefix=${LDAP_DOMAIN/.*/}

# OpenLDAP clients configuration
envsubst <"${TEMPLATES_DIR}/ldap.conf" >ldap.conf

cd /var/lib/openldap
mkdir -p run

if [ $# -eq 0 ]; then
    rm -vf run/*
    exec slapd -d "${LDAP_DEBUGLEVEL}" -F conf.d -h "${tmpl_server_url} ldap://127.0.0.1:${LDAP_PORT} ldapi://"
else
    exec "${@}"
fi
