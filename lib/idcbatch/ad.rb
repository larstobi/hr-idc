$LOAD_PATH << "#{File.dirname(__FILE__)}/ad"

module Idcbatch
    module Ad
        require 'net/ldap'
        require 'idcbatch/ad/connection'
        require 'idcbatch/ad/person'
    end
end
