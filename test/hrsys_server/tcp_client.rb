class TcpClient
    require 'socket'

    def initialize(ip="127.0.0.1", port="8080")
        @ip, @port = ip, port
    end

    def send_message(msg)
        connection do |socket|
            socket.puts(msg)
            response = ""
            while line = socket.gets
                response << line
            end
            response
        end
    end

    def receive_message(msg)
        connection { |socket| socket.gets }
    end

    def connection
        socket = TCPSocket.new(@ip, @port)
        yield(socket)
    ensure
        socket.close
    end
end
