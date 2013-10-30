#!/bin/bash
sleep $1
ldapadd -x -H ldaps://ldaptest.example.com:1636/ -f ../../dev/ldap-development.ldif 1>/dev/null
