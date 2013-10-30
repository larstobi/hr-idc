#!/usr/bin/env ruby
$LOAD_PATH << "#{File.dirname(__FILE__)}"
$LOAD_PATH << "#{File.dirname(__FILE__)}/../../lib"
require 'hrsys_server'
require 'socket'
require 'idcbatch/file_extensions'
require 'time'

trap("INT") do
    puts "Interrupted. Will exit."
    exit
end

servername = "hrsys test server"
xmlfile = File.readfile("#{File.dirname(__FILE__)}/../../dev/persons-development.xml") #.gsub!(/\n/, '')

person_file_dir = File.dirname(__FILE__) + "/../../dev/person-by-pid"
pids = %w(
1291a38f-ce0a-4d54-b12d-9a4c200b8f48
96af69c1-2773-42d5-a69a-9a4c200b8f48
d016203e-3dce-413a-b32c-9a4c200b8f48
f2b38e0d-8076-4aae-bfde-9a4c200b8f48
7a730c8a-f9a6-4982-88ed-9a4c200b8f48
b8f1d6c9-b77b-4bf4-b3e6-9a4c200b8f48
f2972e8a-9422-45dc-ab10-9a4c200b8f48
)

def http_response_ok(content = "", content_type = "text/xml")
    "HTTP/1.1 200 OK\r\n" +
    "Date: #{Time.now.httpdate}\r\n" +
    "Server: Ruby HTTP server\r\n" +
    "Content-Length: #{content.bytesize}\r\n" +
    "Connection: close\r\n" +
    "Content-Type: #{content_type}; charset=utf-8\r\n" +
    "\r\n" + content
end

def http_response_not_found(content = "", content_type = "text/html")
    "HTTP/1.1 404 Not Found\r\n" +
    "Date: #{Time.now.httpdate}\r\n" +
    "Server: Ruby HTTP server\r\n" +
    "Content-Length: #{content.bytesize}\r\n" +
    "Connection: close\r\n" +
    "Content-Type: #{content_type}; charset=utf-8\r\n" +
    "\r\n" + content
end

docroot = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>hrsys server</title>
</head><body>
<h1>hrsys server</h1>
<p>here be dragons</p>
</body></html>"

url_not_found = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
<hr>
<address>hrsys server</address>
</body></html>"

def http_put(payload, filename)
    puts "FILENAME: #{filename}"
    puts "PAYLOAD: #{payload}"
    filehandle = File.open(filename, 'w')
    filehandle.write(payload)
    "HTTP/1.1 200 OK\r\n" +
    "Date: #{Time.now.httpdate}\r\n" +
    "Server: Ruby HTTP server\r\n" +
    "Connection: close\r\n"
end

HrsysServer.run do
    get_handle(/^GET\ \/persons\/modifiedAfter\/.*\ HTTP\/1.1$/i) { http_response_ok(xmlfile) }
    get_handle(/^GET\ \/(\ HTTP\/1.1)?$/i) { http_response_ok(docroot, "text/html") }
    get_handle(/^GET\ \/persons\/all\ HTTP\/1.1$/i) { http_response_ok(xmlfile) }

    pids.each do |pid|
        person_file = File.open(person_file_dir + "/" + pid, 'r')
        get_handle(/^GET\ \/persons\/keys\/#{pid}\ HTTP\/1.1$/i) {
            http_response_ok(File.readfile(person_file))
        }
    end

    pids.each do |pid|
        person_file = person_file_dir + "/" + pid + ".new"
        put_handle(/^PUT\ \/persons\/keys\/#{pid}\ HTTP\/1.1$/i) { |msg|
            http_put(msg, person_file)
        }
    end

    unknown_request(http_response_not_found(url_not_found))
end
