#!/usr/bin/env ruby

module Mine
  class TCPHandler
    include Celluloid::IO

    #
    # Creates a TCP handler based on the handler of Celluloid-io
    #
    def initialize host, port, userdir
      @host, @port = host, port
      @userdir = userdir
      @server = TCPServer.new @host, @port
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
      client = Client.new socket, host, @userdir, :tcp
      loop do 
        client.readAndProcessRequest
      end
    rescue EOFError
      client.exit :clientQuit
    end
  end
end
