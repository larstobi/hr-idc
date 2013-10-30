module Idcbatch
    module Ad
        class Person
            attr_accessor :dn, :sam_account_name, :given_name, :sn, :extension_attribute_9, :email

            def initialize(ad, entry)
                @ad = ad
                @dn = entry.dn
                @company = entry['company'] ? entry['company'][0] : nil
                @employee_number = entry['employeeNumber'] ? entry['employeeNumber'][0] : nil
                @sam_account_name = entry['sAMAccountName'] ? entry['sAMAccountName'][0] : nil
                @given_name = entry['givenName'] ? entry['givenName'][0] : nil
                @sn = entry['sn'] ? entry['sn'][0] : nil
                @employee_type = entry['employeeType'] ? entry['employeeType'] : nil
                @extension_attribute_9 = entry['extensionAttribute9'] ? entry['extensionAttribute9'][0] : nil

                if entry['proxyAddresses'] and !entry['proxyAddresses'].empty? then
                    # Select only the first entry that begins with "SMTP".
                    @email = entry['proxyAddresses'].select { |x| x =~ /^SMTP/ }[0]
                    # Remove protocol
                    @email.gsub!(/\A\w+\:\ */, "") unless @email.nil?
                end
            end

            def to_s
                "#{@sam_account_name}\t#{@employee_number}\t#{@company}\t" +
                "#{@given_name}\t#{@sn}\t#{@email}\t#{@dn}"
            end

            def quit?
                @extension_attribute_9 and @extension_attribute_9 == "Change:Quit"
            end

            def quit!
                @extension_attribute_9 = "Change:Quit"
                @ad.update!(@dn, 'extensionAttribute9', @extension_attribute_9)
            end

            def unquit!
                @extension_attribute_9 = nil
                @ad.update!(@dn, 'extensionAttribute9', @extension_attribute_9)
            end

            def sn! new_name
                @sn = new_name
                @ad.update!(@dn, 'sn', @sn)
                @extension_attribute_9 = "Change:Name"
                @ad.update!(@dn, 'extensionAttribute9', @extension_attribute_9)
            end

            def given_name! new_name
                @given_name = new_name
                @ad.update!(@dn, 'givenName', @given_name)
                @extension_attribute_9 = "Change:Name"
                @ad.update!(@dn, 'extensionAttribute9', @extension_attribute_9)
            end

            def email_sans_protocol
                if @email
                    return @email.gsub(/\A\w+\:/, "")
                end
            end
        end
    end
end
