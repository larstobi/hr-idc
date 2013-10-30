#!/usr/bin/ruby -KU
require 'rubygems'
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib"
require 'idcbatch'
require 'logger'

unless ARGV.length == 1 or ARGV.length == 0
    puts "Usage: #{$0} [config_file]"
    exit 1
else
    if ARGV.length == 1
        config_file = ARGV.shift
    else
        config_file = "/etc/idcbatch.yml"
    end
end

$config = Idcbatch::ReadConfig.read(config_file)
if STDIN.tty?
    STDOUT.sync
    $LOG = Logger.new(STDOUT)
else
    $LOG = Logger.new($config[:log][:file])
end
$LOG.level = Logger.const_get $config[:log][:level]

hrs = Idcbatch::Hrsys::Connection.new($config[:hrsys])

# Fetch all persons from HR-system
hrs_persons = hrs.all_persons.find_all do |hrs_person|
    hrs_person.has_ad_account?
end
$LOG.debug("All person objects retrieved from HR-system.")

# For each person, lookup person in AD and compare email.
ad = Idcbatch::Ad::Connection.new($config[:ad])
hrs_persons.each do |hrs_person|
    username = hrs_person.sam_account_name

    unless username.nil? or hrs_person.type.nil?
        if hrs_person.type == "employee" or hrs_person.type == "contractor"
            # Lookup person by username in Active Directory
            ad_person = ad.account(username)

            # Update the email in HR-system if we found the account in AD.
            unless (ad_person.nil? or ad_person.email.nil?) or (hrs_person.email == ad_person.email)
                # Overwrite email on HR-system with email from AD.
                hrs.update_email!(hrs_person.type, hrs_person.pid, ad_person.email)
                $LOG.info("Updated in HR-system: #{username} with new email: #{ad_person.email} " +
                          "Old email: #{hrs_person.email}")
            else
                $LOG.warn("Person not found in AD: #{username}.") if ad_person.nil?
            end
        end
    end
end
