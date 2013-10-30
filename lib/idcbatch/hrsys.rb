$LOAD_PATH << "#{File.dirname(__FILE__)}/hrsys"
module Idcbatch
    module Hrsys
        require 'yaml'
        require 'date'
        require 'logger'
        require 'restclient'
        require 'rexml/document'
        require 'idcbatch/hrsys/connection'
        require 'idcbatch/hrsys/person'
        require 'idcbatch/hrsys/person_parser'
        require 'idcbatch/file_extensions'
    end
end
