require 'yaml'

module Idcbatch
    class ReadConfig
        def self.read config_file
            @config = YAML.load_file(config_file)

            if !@config['ad']['host'].nil? and @config['ad']['host'].match(/[a-zA-z0-9.]+/) and
                !@config['ad']['hosts'].nil? and @config['ad']['hosts'].match(/[a-zA-z0-9.]+/)
                raise "Error: Both hosts and host specified in config file " +
                "#{@config['ad']['hosts']} and #{@config['ad']['host']}"
                exit 1
            elsif !@config['ad']['host'].nil? and @config['ad']['host'].match(/[a-zA-z0-9.]+/)
                @config['ad']['hosts'] = [@config['ad']['host']]
                @config['ad'].delete('host')
            end

            if @config['ad']['ssl'] == 'true'
                @config['ad']['ssl'] = true
            else
                @config['ad']['ssl'] = false
            end
            self.keys_to_symbols(@config)
        end

        def self.keys_to_symbols hash
            new_hash = {}
            hash.each do |key,value|
                if value.class == Hash
                    new_hash[key.to_sym] = self.keys_to_symbols(value)
                else
                    new_hash[key.to_sym] = value
                end
            end
            new_hash
        end
    end
end
