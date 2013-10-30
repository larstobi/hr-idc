require 'date'
require 'string_extensions'

module Idcbatch
    module Hrsys
        class Person
            attr_accessor :pid, :firstname, :lastname, :work_to_date, :sam_account_name, :email, :type

            HRS_XMLNS = 'http://example.com/namespaces/hrsys'

            def hrs_xmlns
                HRS_XMLNS
            end

            def initialize(person)
                @firstname = person[:firstname]
                @lastname = person[:lastname]
                if person[:ad_account] == "true"
                    @has_ad_account = true
                else
                    @has_ad_account = false
                end
                @sam_account_name = person[:sam_account_name] if has_ad_account?
                if person[:work_to_date] and
                    person[:work_to_date].match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}/)
                    @work_to_date = person[:work_to_date]
                end
                @email = person[:email]
                @pid = person[:pid]
                @type = person[:type]
            end

            def has_ad_account?
                @has_ad_account
            end

            def to_s
                "#{firstname} #{lastname}" 
            end

            def still_employed?
                if @work_to_date and !@work_to_date.empty? and @work_to_date.to_date < Date.today
                    return false
                end
                true
            end

            def has_quit?
                !still_employed?
            end
        end
    end
end
