#!/usr/bin/env ruby
puts `ldapsearch -x -H ldaps://ldaptest.example.com:1636/  "(objectclass=*)"`
