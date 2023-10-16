#
# Copyright (C) 2023 Nethesis S.r.l.
# SPDX-License-Identifier: GPL-3.0-or-later
#

CC=gcc

all: ppcheck.so

ppcheck.o: ppcheck.c
	$(CC) -O2 -fpic -Wall -I./openldap/include -I./openldap/servers/slapd -c ppcheck.c

ppcheck.so: ppcheck.o
	$(CC) -shared -o ppcheck.so ppcheck.o

install: ppcheck.so
	install -m 0755 ppcheck.so /usr/lib/openldap

clean:
	rm -f ppcheck.so ppcheck.o
