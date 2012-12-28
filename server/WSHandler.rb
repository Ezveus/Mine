#!/usr/bin/env ruby

require 'celluloid/io'

load 'server/Log.rb'
load "server/Client.rb"
load 'server/Socket.rb'

module Mine
  class WSHandler
    include Celluloid::IO

    def initialize host, port
      @host, @port = host, port
      @server = TCPServer.new @host, @port
      run!
    end

    def finalize
      @server.close if @server
    end
    
    def run
      loop do
        handle_connection! @server.accept
      end
    end
    
    def handle_connection socket
      _, port, host = socket.peeraddr
      puts "*** Received connection from #{host}:#{port}"
      msock = Socket.new socket
      client = Client.new msock
      loop do
        if msock.status == :disconnected
          msock.connect
        elsif msock.status == :connected
          client.readAndProcessRequest
        end
      end
    rescue EOFError
      puts "*** #{host}:#{port} disconnected"
      client.exit
    end
  end
end
