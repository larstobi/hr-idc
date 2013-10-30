#!/usr/bin/env ruby
$VERBOSE = true
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib" << "#{File.dirname(__FILE__)}/../test"
require 'ad'

@ad = Ad.new(
        :base_dn => 'dc=example,dc=com',
        :host => 'ldaptest.example.com',
        :port => 1636,
        :bind_dn => '',
        :password => '',
        :ssl => true
)

person = @ad.account('username')

person.quit!(@ad)

person = @ad.account('username')

person.unquit!(@ad)

person = @ad.account('username')
