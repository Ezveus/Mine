module Mine
  module Socket
    def self.create rhost, rport, type = :tcp
      case type
      when :tcp then Celluloid::IO::TCPSocket.new rhost, rport
      when :wsp then WEBSocket::Socket.new rhost, rport
      when :tcps then Celluloid::IO::TCPServer.new rhost, rport
      when :wsps then WEBSocket::Server.new rhost, rport
      else raise "Unknown socket type"
      end
    end
  end
end
