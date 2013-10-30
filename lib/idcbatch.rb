$LOAD_PATH << "#{File.dirname(__FILE__)}/idcbatch"

module Idcbatch
    require "idcbatch/ad"
    require "idcbatch/hrsys"
    require "idcbatch/read_config"
    IDCBATCHVERSION = "1.2"

    def self.version
        IDCBATCHVERSION
    end
end
