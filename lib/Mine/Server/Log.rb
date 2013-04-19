module Mine
  module Log
    #
    # Isn't the code and the names clear enough
    #
    module Server
      def self.log str
        puts "--> #{str}"
      end

      def self.error errMsg
        $stderr.puts "!! => #{errMsg}"
      end

      def self.info info
        puts "==> #{info}"
      end

      def self.debug msg
        $stderr.puts "--> #{str}"
      end
    end

    module Client
      def self.log str
        puts "[Client] #{str}"
      end

      def self.error errMsg
        $stderr.puts "[Client] Error : #{errMsg}"
      end

      def self.info info
        puts "[Client] Info : #{info}"
      end

      def self.debug str
        $stderr.puts "[Client] #{str}"
      end
    end

    module WSClient
      def self.log str
        puts "[WSClient] #{str}"
      end

      def self.error errMsg
        $stderr.puts "[WSClient] Error : #{errMsg}"
      end

      def self.info info
        puts "[WSClient] Info : #{info}"
      end

      def self.debug str
        $stderr.puts "[WSClient] #{str}"
      end
    end
  end
end
