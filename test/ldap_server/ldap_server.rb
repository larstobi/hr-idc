#!/usr/bin/env ruby
$VERBOSE = true

# This is a trivial LDAP server which just stores directory entries in RAM.
# It does no validation or authentication.

$LOAD_PATH << "#{File.dirname(__FILE__)}"
$LOAD_PATH << "#{File.dirname(__FILE__)}/../../../ruby-ldapserver/lib"
require 'ldap/server'
require 'hash_operation'
trap("INT") do
    puts "Interrupted. Will exit."
    exit
end

# This is the shared object which carries our actual directory entries.
# It's just a hash of {dn=>entry}, where each entry is {attr=>[val,val,...]}
directory = {}

# Listen for incoming LDAP connections. For each one, create a Connection
# object, which will invoke a HashOperation object for each request.
s = LDAP::Server.new(
	:port			=> 1636,
	:nodelay		=> true,
	:listen			=> 10,
	:ssl_key_file		=> "ldaptest/ldaptest.example.key",
	:ssl_cert_file		=> "ldaptest/ldaptest.example.crt",
	:ssl_dhparams		=> "ldaptest/dhparams.pem",
	:ssl_on_connect		=> true,
	:operation_class	=> HashOperation,
	:operation_args		=> [directory]
)
s.run_tcpserver
s.join
