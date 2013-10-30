module Idcbatch
    module Ad
        class Connection
            ATTRS = %w{ company employeeNumber sAMAccountName proxyAddresses givenName sn employeeType extensionAttribute9 }
            attr_accessor :person

            def initialize args
                @persons = {}
                @args = self.to_ldap_args(args)
                @hosts = @args[:hosts]
                self.connect
            end

            def to_ldap_args(args)
                ldap_args = {}
                ldap_args[:hosts] = []
                if args[:hosts].class == Array and !args[:hosts].empty?
                    ldap_args[:hosts] = args[:hosts]
                end
                if args[:host].class == String and !args[:host].empty?
                    ldap_args[:hosts] << args[:host]
                end

                ldap_args[:base] = args[:base_dn] if args[:base_dn]
                ldap_args[:encryption] = :simple_tls if args[:ssl]
                ldap_args[:port] = args[:port] if args[:port]

                auth = {}
                auth[:username] = args[:bind_dn] if args[:bind_dn]
                auth[:password] = args[:password] if args[:password]
                if auth[:username] and auth[:password]
                    auth[:method] = :simple
                    ldap_args[:auth] = auth
                end

                ldap_args
            end

            def connect
                @connections = []
                @hosts.each do |host|
                    args = @args
                    args[:host] = host
                    conn = Net::LDAP.new(args)
                    @connections << conn
                end
                @next_connection_index = 0
            end

            def update!(dn, attribute_name, attribute_value)
                if attribute_value.nil?
                    connection.delete_attribute(dn, attribute_name)
                else
                    connection.replace_attribute(dn, attribute_name, attribute_value)
                end
            end

            def find_all_by_sam_account_name(sam_account_name)
                find_all_by_filter "(&(objectClass=user)(sAMAccountName=#{sam_account_name}))"
            end

            def account(username)
                return nil if username.nil?
                result = self.find_all_by_sam_account_name(username)
                if result.size == 1
                    return result[0]
                elsif result.size > 1
                    $LOG.debug("More than one result: #{result.size} results. Don't know what to with #{username}.")
                    nil
                else
                    return nil
                end
            end

            def cleanup
                @connections.each { |c| c.unbind }
            end

            private

            def find_all_by_filter(search_filter)
                results = []
                connection.search(:base => @args[:base], :attributes => ATTRS,
                :filter => search_filter, :return_result => true) { |entry|
                    results << Idcbatch::Ad::Person.new(self, entry)
                }
                results
            end

            def connection
                conn = @connections[@next_connection_index]
                if ((@connections.length - 1) == @next_connection_index)
                    @next_connection_index = 0
                else
                    @next_connection_index += 1
                end
                conn
            end
        end
    end
end
