require 'rexml/streamlistener'

module Idcbatch
    module Hrsys
        class PersonParser
            include REXML
            include StreamListener

            def initialize(raw_xml)
                @raw_xml = raw_xml
                @current_person = nil
                @current_element = nil
                @persons = []
            end

            def parse
                parser = Parsers::StreamParser.new(@raw_xml, self)
                parser.parse
                @persons
            end

            # REXML::StreamListener#tag_start is called when a tag is encountered
            # in the document.
            def tag_start name, attrs
                case name
                when 'person'
                    @current_person = {}
                    @current_person[:pid] = attrs['pid']
                    @current_person[:type] = attrs['xsi:type']
                else
                    @current_element = name
                end
            end

            # REXML::StreamListener#tag_end is called when the end tag is reached.
            def tag_end name
                case name
                when 'person'
                    @persons << @current_person
                    @current_person = nil
                end
            end

            # REXML::StreamListener#text is called when text is encountered
            # in the document.
            def text text
                case @current_element
                when 'firstname'
                    @current_person[:firstname] = text
                when 'lastname'
                    @current_person[:lastname] = text
                when 'adAccount'
                    @current_person[:ad_account] = text
                when 'accountId'
                    @current_person[:sam_account_name] = text
                when 'workToDate'
                    @current_person[:work_to_date] = text
                when 'emailAddress'
                    @current_person[:email] = text
                end
                # Reset the current element som we don't pick up empty text.
                @current_element = nil
            end

            def xmldecl(*args)
                nil
            end
        end
    end
end
