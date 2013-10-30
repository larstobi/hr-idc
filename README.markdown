Description
==========
This is a batch program that syncronizes data between a HR system and
an Active Directory service. The program logs into the HR system using REST,
and reads an XML list of person objects that has been changed in the last
time interval. Then it will update the data in the Active Directory service.

Install
=======
Build the gem and install it:

    $ rake gem
    $ gem install --local pkg/idcbatch-x.x.x.gem

Place the configuration in '/etc/idcbatch.yml'. Use an example template from
'config/local.yml' or 'config/development.yml'.

Run the binaries manually or periodically using cron.

    $ email.rb
    $ resignation.rb
    $ namechange.rb

Requirements
============
Tested with Ruby 1.8.7, needs some minor patching to work with Ruby 1.9.

Depends on Rubygems 'net-ldap' and 'rest-client'.

Test
====
Start a local HR system server in a terminal and run:

    $ cd test/hrsystem_server
    $ ./runserver.rb

Run the unit tests and functional tests in another terminal:

    $ rake test
