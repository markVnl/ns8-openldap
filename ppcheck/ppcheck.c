/*
 * Copyright (C) 2023 Nethesis S.r.l.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <portable.h>
#include <slap.h>

int check_password (char *pPasswd, struct berval *pErrmsg, Entry *pEntry, struct berval *pArg);

int check_password (char *pPasswd, struct berval *pErrmsg, Entry *pEntry, struct berval *pArg) {
    int match_digit = 0,
        match_lowercase = 0,
        match_uppercase = 0,
        match_other = 0;

    for (int i=0; i<strlen(pPasswd); i++) {
        if (LDAP_RANGE(pPasswd[i], '0', '9')) {
            match_digit = 1;
        } else if (LDAP_RANGE(pPasswd[i], 'a', 'z')) {
            match_lowercase = 1;
        } else if (LDAP_RANGE(pPasswd[i], 'A', 'Z')) {
            match_uppercase = 1;
        } else {
            match_other = 1;
        }
    }

    // Password requirement: at least one char from three+ groups
    if(match_digit + match_lowercase + match_uppercase + match_other >= 3) {
        return(LDAP_SUCCESS);
    }

    return(LDAP_OTHER);
}
