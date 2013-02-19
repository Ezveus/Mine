#!/usr/bin/env ruby

module Mine
  class WSHandler
    include Celluloid::IO

    def initialize host, port, userdir
      @host, @port = host, port
      @userdir = userdir
      @server = WEBSocket::Server.new @host, @port
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
      client = Client.new socket, host, @userdir, :wsp
      loop do
        client.readAndProcessRequest
      end
    rescue EOFError
      puts "*** #{host}:#{port} disconnected"
      client.exit
    end
  end
end
