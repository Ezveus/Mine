#!/usr/bin/env ruby

module Mine
  class WSHandler
    include Celluloid::IO

    #
    # creates a WebSocket handler based on the handler of Celluloid-io
    #
    def initialize host, port, userdir
      @host, @port = host, port
      @userdir = userdir
      @server = WEBSocket::Server.new @host, @port
      run!
    end

    #
    # Method called when the server is shutdowned
    #
    def finalize
      @server.close if @server
    end
    
    #
    # Method called to handle the clients connections
    #
    def run
      loop do
        handle_connection! @server.accept
      end
    end
    
    #
    # Method handling the client connection and creating a client
    #
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
