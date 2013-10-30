module Idcbatch
    module Hrsys
        class Connection
            attr_accessor :base_url
            include Enumerable

            #$LOG = Logger.new(STDERR)
            STDOUT.sync = true
            HRS_XMLNS = 'http://example.com/namespaces/hrsys'

            def hrs_xmlns
                HRS_XMLNS
            end

            def initialize args = {}
                @base_url = args[:base_url]
                raise "No base URL error." unless @base_url
                @persons = []
                @raw_xml = nil
            end

            def each
                @persons.each do |person|
                    yield person
                end
            end

            def self.all_persons
                hrsys = Hrsys.new
                hrsys.instance_eval(&block)
                hrsys.all_persons
            end

            def all_persons
                url = "#{@base_url}/persons/all"
                $LOG.debug "HR-system GET URL: #{url}"
                result = RestClient.get(url)
                unless result and result.code == 200
                    raise "Unable to load data for #{url} from server"
                end
                @raw_xml = result.body
                persons if persons.empty?
                self
            end

            def self.modified_after(time = (Time.now - (2*86400)), &block)
                hrsys = Hrsys.new(time)
                hrsys.instance_eval(&block)
                hrsys.modified_after
            end

            def modified_after(time = (Time.now - (2*86400)))
                url = "#{@base_url}/persons/modifiedAfter/#{time.to_i * 1000}"
                $LOG.debug "HR-system GET URL: #{url}"
                result = RestClient.get(url)
                unless result and result.code == 200
                    raise "Unable to load data for #{url} from server"
                end
                @raw_xml = result.body
                persons if persons.empty?
                self
            end

            def persons
                # Empty XML set? Load from @base_url!
                unless @raw_xml
                    self.modified_after
                end
                # @person Array empty? Load from XML set.
                if @persons.empty?
                    tmp_persons = []
                    parsed = PersonParser.new(@raw_xml).parse
                    parsed.each do |person_hash|
                        tmp_persons << Person.new(person_hash)
                    end
                    @persons = tmp_persons
                end
                @persons
            end

            def person_by_pid type, pid
                url = "#{@base_url}/#{type}s/keys/#{pid}"
                $LOG.debug("person_by_pid: #{url}")
                result = RestClient.get(url)
                unless result and result.code == 200
                    raise "Unable to load data from #{url} from server"
                end
                result.body
            end

            def update_person!(type, pid, doc)
                formatter = REXML::Formatters::Default.new
                xml = String.new
                formatter.write(doc, xml)

                begin
                    url = "#{@base_url}/#{type}s/keys/#{pid}"
                    result = RestClient.put(url, xml, :content_type => 'application/xml')
                    unless result.code == 204
                        $LOG.error "PUT #{pid} failed: #{result.code}"
                    end
                rescue Exception => e
                    $LOG.error e
                end
            end

            def update_email!(type, pid, email)
                unless email.valid_email?
                    $LOG.warn("Ignoring invalid email for person with pid=#{pid}: #{email}")
                    return nil
                end

                xml = person_by_pid(type, pid)
                doc = REXML::Document.new(xml)

                doc.elements.each("/#{type}/emailAddress") do |element|
                    element.delete_attribute('xsi:nil')
                    element.text = email
                end

                update_person!(type, pid, doc)
            end
        end
    end
end
