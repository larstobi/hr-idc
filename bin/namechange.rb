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
    $LOG = Logger.new(STDOUT)
else
    $LOG = Logger.new($config[:log][:file])
end
$LOG.level = Logger.const_get $config[:log][:level]

changed_hrs_persons = Idcbatch::Hrsys::Connection.new($config[:hrsys]
    ).modified_after.find_all do |hrs_person|
        hrs_person.has_ad_account?
end

ad = Idcbatch::Ad::Connection.new($config[:ad])
changed_hrs_persons.each do |hrs_person|
    username = hrs_person.sam_account_name

    if username.nil? or username == ""
        $LOG.warn "Person has AD account, but no username."
    else
        $LOG.debug "Lookup in AD: #{username}"
        # Lookup person by username in Active Directory
        ad_person = ad.account(username)
    end

    # Update the attribute in AD unless we didn't find the account in AD.
    unless ad_person.nil?
        ad_firstname = ad_person.given_name
        ad_lastname = ad_person.sn
        hrs_firstname = hrs_person.firstname
        hrs_lastname = hrs_person.lastname

        if ad_lastname != hrs_lastname
            ad_person.sn!(hrs_lastname)
            $LOG.info "Updated in AD: #{username} (lastname: #{ad_lastname} >> #{hrs_lastname})"
        end

        if ad_firstname != hrs_firstname
            ad_person.given_name!(hrs_firstname)
            $LOG.info "Updated in AD: #{username} (firstname: #{ad_firstname} >> #{hrs_firstname})"
        end
    else
        $LOG.warn "Person not found in AD: #{username}"
    end
end
