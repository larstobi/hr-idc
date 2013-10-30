Description
==========
This is a batch program that syncronizes data between a HR system and
an Active Directory service. The program logs into the HR system using REST,
and reads an XML list of person objects that has been changed in the last
time interval. Then it will update the data in the Active Directory service.

Test
====
Start a local HR system server in a terminal and run:

    $ cd test/hrsystem_server
    $ ./runserver.rb

Run the unit tests and functional tests in another terminal:

    $ rake test
