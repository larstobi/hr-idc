require 'test/unit'
require 'rubygems'
require 'logger'
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib" << "#{File.dirname(__FILE__)}/../test"
require 'test_unit_extensions'
require 'idcbatch'

class TestIdcbatchAd < Test::Unit::TestCase
    def setup
        @ad = Idcbatch::Ad::Connection.new(
            :base_dn => 'dc=example,dc=com',
            :hosts => ['ldaptest.example.com'],
            :port => 1636,
            :bind_dn => '',
            :password => '',
            :ssl => true
        )
        $LOG = Logger.new("rake_test.log")
    end

    must "return Array object when find_all_by_sam_account_name" do
        assert_instance_of(Array, @ad.find_all_by_sam_account_name("username"))
    end

    must "return exactly one result when find_all_by_sam_account_name" do
         result = @ad.find_all_by_sam_account_name("username")
         assert(result.size == 1, "Wrong number of results: #{result.size}")
    end

    must "return correctly modified attribute after update" do
        username = "username"
        @ad.account(username).quit!
        ad_person_2 = @ad.account(username)
        assert_equal(ad_person_2.quit?, true)
    end

    must "return missing attribute after delete" do
        username = "username"
        @ad.account(username).unquit!
        ad_person_2 = @ad.account(username)
        assert_equal(ad_person_2.quit?, nil)
    end
end
