#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'socket'

$host = "localhost"
$port = 4242

$host = ARGV[0] if ARGV[0]
$port = ARGV[1] if ARGV[1]
socket = TCPSocket.new($host, $port)

msg = "(nil)"
while result = select([$stdin, socket], nil, nil, nil) and msg
  if result[0][0] == $stdin and (msg = $stdin.gets) != "\n"
    socket.puts msg
  elsif result[0][0] == socket and (msg = socket.gets) != ""
    puts msg
  end
end
socket.close
