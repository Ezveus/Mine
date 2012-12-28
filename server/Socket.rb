require 'celluloid/io'
require 'websocket'

module Mine
  class Socket
    attr_reader :status

    def self.from_ruby_socket rbsock
      csock = Celluloid::IO::TCPSocket.from_ruby_socket rbsock
      Socket.new csock
    end

    def acquire_ownership type
      @socket.acquire_ownership type
    end

    def close
      @socket.close
    end

    def connect
      @handshake = WebSocket::Handshake::Server.new
      msg = @socket.readpartial 4096
      @handshake << msg
      until @handshake.finished?
        msg = @socket.readpartial 4096
        @handshake << msg
      end
      if @handshake.valid?
        @socket.write @handshake.to_s
        @status = :connected
      end
    end

    def evented?
      @socket.evented?
    end

    def initialize socket
      @socket = socket
      @status = :disconnected
    end

    def read length = nil, buffer = nil
      s = @socket.read length, buffer
      frame = WebSocket::Frame::Incoming::Server.new :version => @handshake.version
      frame << s
      frame.next.to_s
    end

    def readpartial length, buffer = nil
      s = @socket.readpartial length, buffer
      frame = WebSocket::Frame::Incoming::Server.new :version => @handshake.version
      frame << s
      frame.next.to_s
    end

    def release_ownership type
      @socket.release_ownership type
    end

    def to_io
      @socket
    end

    def wait_readable
      @socket.wait_readable
    end

    def wait_writable
      @socket.wait_writable
    end

    def write s
      frame = WebSocket::Frame::Outgoing::Server.new :version => @handshake.version, :data => s, :type => :text
      @socket.write frame.to_s
    end

    def << s
      frame = WebSocket::Frame::Outgoing::Server.new :version => @handshake.version, :data => s, :type => :text
      @socket << frame.to_s
    end
  end
end
