#!/usr/bin/env ruby
$LOAD_PATH << "#{File.dirname(__FILE__)}"
require 'tcp_client'

client = TcpClient.new
responses = []
["GET /", "GET /favicon.ico"].each do |msg|
    puts client.send_message(msg)
end
