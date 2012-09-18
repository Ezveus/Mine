#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'socket'

class Client
  attr_reader :socket, :id

  def initialize(socket, id)
    @socket = socket
    @id = id
  end

  def puts(msg)
    @socket.puts msg
  end
  def gets
    @socket.gets
  end
  def disconnect
    @socket.close
  end
end

$color_r = "\033[91m"
$color_g = "\033[92m"
$color_n = "\033[0m"
$port = 4242
$clients = []


def connection_msg(client)
  puts $color_g + "Client " + client.id.to_s + " conected." + $color_n
  client.puts $color_g + "Welcome client " + client.id.to_s + $color_n
  $clients.each do |x|
    if x.socket != client.socket
      x.puts $color_g + "Client " + client.id.to_s + " is now conected." + $color_n
    end
  end
end

def disconnection_msg(client)
  puts $color_r + "Client " + client.id.to_s + " is now disconnected." + $color_n
  $clients.each do |x|
    if x.socket != client.socket
      x.puts $color_r + "Client " + client.id.to_s + " is now disconnected." + $color_n
    end
  end
end

def chat(client)
  msg = "(nil)"
  while result = select([client.socket], nil, nil, nil) and msg
    if result[0][0] == client.socket and (msg = client.gets)
      puts "From client " + client.id.to_s + " : " + msg
      $clients.each do |x|
        x.puts "client " + client.id.to_s + " : " + msg if x.socket != client.socket
      end
    end
  end
end

$port = ARGV[0] if ARGV[0]
server = TCPServer.new $port
id = 0
loop do
  Thread.start(server.accept) do |socket|
    id += 1
    client = Client.new(socket, id)
    $clients += [client]
    connection_msg(client)

    chat(client)

    disconnection_msg(client)
    client.disconnect
    $clients -= [client]
  end
end
