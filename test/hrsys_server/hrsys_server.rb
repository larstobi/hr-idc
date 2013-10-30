class HrsysServer
    require 'logger'

    def initialize(port=8080, logfile='server.log')
        @server = TCPServer.new('127.0.0.1', port)
        $LOG = Logger.new(logfile, 'daily')
        $LOG.datetime_format = '%d/%b/%Y:%T %Z'
        @get_handlers = {}
        @put_handlers = {}
        @unknown_request = "HTTP/1.1 404 Not Found\n\nNot Found"
    end

    def self.run(port=8080, &block)
        server = HrsysServer.new(port)
        server.instance_eval(&block)
        server.run
    end
    
    def get_handle(pattern, &block)
        @get_handlers[pattern] = block
    end
    def put_handle(pattern, &block)
        @put_handlers[pattern] = block
    end
    
    def unknown_request(response)
        @unknown_request = response
    end

    def run
        while session = @server.accept
            msg = session.gets.chomp
            $LOG.info msg
            match = nil

            @get_handlers.each do |pattern,block|
                if match = msg.match(pattern)
                    session.puts(block.call(match))
                    session.close
                    break
                end
            end

            @put_handlers.each do |pattern,block|
                if match = msg.match(pattern)
                    session.puts(block.call(msg))
                    session.close
                    break
                end
            end

            unless match
                session.puts @unknown_request
                $LOG.error msg
                session.close
            end
        end
    end
end
