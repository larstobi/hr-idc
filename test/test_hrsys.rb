require 'test/unit'
require 'rubygems'
require 'logger'
$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib" << "#{File.dirname(__FILE__)}/../test"
require 'test_unit_extensions'
require 'idcbatch'

class TestHrsys < Test::Unit::TestCase
    def setup
        @hrsys = Idcbatch::Hrsys::Connection.new(:base_url => "http://localhost:8080")
        #:base_url => "file://test/persons-development.xml"
        $LOG = Logger.new("rake_test.log")
    end

    must "return an array when requesting persons" do
        assert_instance_of(Array, @hrsys.persons)
    end

    must "return an Array of Idcbatch::Hrsys::Person when loading objects" do
        @hrsys.persons.each do |element|
            assert_instance_of(Idcbatch::Hrsys::Person, element)
        end
    end

    must "return minimum size of two persons" do
        # Test against empty result set.
        size = @hrsys.persons.size
        assert(size >= 2, "Too small result: #{size}")
    end

    must "return the correct number of ad accounts from test set" do
        # (grep '<adAccount>true</adAccount>' persons-development.xml|wc -l)
        correct_number = 12
        actual_number = @hrsys.persons.find_all do |person|
            person.has_ad_account?
        end.size
        assert_equal(correct_number, actual_number)
    end
end
