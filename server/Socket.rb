require 'celluloid/io'
require 'WEBSocket'

module Mine
  module Socket
    def self.create rhost, rport, type = :tcp
      if type == :tcp
        Celluloid::IO::TCPSocket.new rhost, rport
      elsif type == :wsp
        WEBSocket::Socket.new rhost, rport
      else
        Celluloid::IO::TCPSocket.new rhost, rport
      end
    end
  end
end
