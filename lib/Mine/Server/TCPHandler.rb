#!/usr/bin/env ruby

module Mine
  class TCPHandler
    include Celluloid::IO

    def initialize host, port, userdir
      @host, @port = host, port
      @userdir = userdir
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
      client = Client.new socket, host, @userdir, :tcp
      loop do 
        client.readAndProcessRequest
      end
    rescue EOFError
      client.exit :clientQuit
    end
  end
end
