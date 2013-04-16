module MineClient
  class Connection
    include Singleton

    def config
      f = File.open('/etc/mine.conf', 'r')
      begin
        catch :eof do
          loop do
            line = f.readline.strip
            case line
            when /^login:$/
              @login = f.readline.strip
            when /^passwd:$/
              @passwd = f.readline.strip
            when /^host:$/
              @host = f.readline.strip
            when /^port:$/
              @port = f.readline.strip
            end
          end
        end
      rescue => ex
      ensure
        f.close
      end
    end

    def connect
      @socket = Celluloid::IO::TCPSocket.new @host, @port
    end

    def authenticate
      auth_hash = {
        :id => SecureRandom.uuid,
        :name => @login,
        :pass => @passwd
      }
      @socket.write "AUTHENTICATE=#{JSON.dump auth_hash}"
    end

    def signup name
      signup_hash = {
        :id => SecureRandom.uuid,
        :name => name,
        :pass => passwd,
        :email => mail,
        :website => site
      }
      @socket.write "SIGNUP=#{JSON.dump signup_hash}"
    end
  end
end
