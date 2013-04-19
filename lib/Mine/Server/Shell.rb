#!/usr/bin/env ruby

module Mine
  #
  # The method are acting as their sisters in a UNIX system
  #
  module Shell
    #
    # Method called when the argument of the request SHELL is 'Mkdir'
    #
    def self.mkdir args, response, client
      unless Dir.exist? "#{client.user.dir}/#{args[0]}"
        begin
          self.createIntermediateDirs args[0], client.user.dir
          Dir.mkdir "#{client.user.dir}/#{args[0]}", 0700
        rescue
          Log::Client.error "no such directory"
          response.status = Constant::PathError
          return Constant::Fail
        end
        return Constant::Success
      end
      response.status = Constant::AlreadyCreated
      Constant::Fail
    end

    #
    # Method called when the argument of the request SHELL is 'Rmdir'
    #
    def self.rmdir args, response, client
      if Dir.exist? "#{client.user.dir}/#{args[0]}"
        if Dir.entries("#{client.user.dir}/#{args[0]}").size == 2
          begin
            Dir.rmdir "#{client.user.dir}/#{args[0]}"
          rescue
            Log::Client.error "Directory not empty"
            response.status = Constant::DirectoryNotEmpty
            return Constant::Fail
          end
          return Constant::Success
        end
        response.status = Constant::DirectoryNotEmpty
        return Constant::Fail
      end
      response.status = Constant::PathError
      Constant::Fail
    end

    #
    # Method called when the argument of the request SHELL is 'Rm'
    #
    def self.rm args, response, client
      if File.exist? "#{client.user.dir}/#{args[0]}"
        begin
          File.delete "#{client.user.dir}/#{args[0]}"
        rescue
          response.status =  Constant::UnknownFile
          return Constant::Fail
        end
        return Constant::Success
      end
      response.status = Constant::PathError
      Constant::Fail
    end

    #
    # Method called when the argument of the request SHELL is 'Ls'
    #
    def self.ls args, response, client
      if Dir.exist? "#{client.user.dir}/#{args[0]}"
        ls = Dir.entries "#{client.user.dir}/#{args[0]}"
        ls.size.times do |i|
          ls[i] = [ls[i], File.directory?(ls[i])]
        end
        response.info["ls"] = ls
        return Constant::Success
      end
      response.status = Constant::PathError
      Constant::Fail
    end

    #
    # Method called when the argument of the request SHELL is 'Cp'
    #
    def self.cp args, response, client
      if File.exist? "#{client.user.dir}/#{args[0]}"
        if Dir.exist? (File.dirname "#{client.user.dir}/#{args[1]}")
          self.copyFile args, client
          return Constant::Success
        end
        response.status = Constant::PathError
        return Constant::Fail
      end
      response.status = Constant::UnknownFile
      Constant::Fail
    end

    #
    # Method called when the argument of the request SHELL is 'Touch'
    #
    def self.touch args, response, client
      unless File.exist? "#{client.user.dir}/#{args[0]}"
        File.new "#{client.user.dir}/#{args[0]}", File::CREAT
        return Constant::Success
      end
      response.status = Constant::PathError
      Constant::Fail 
    end

    #
    # Method called when the argument of the request SHELL is 'Mv'
    #
    def self.mv args, response, client
      if File.exist? "#{client.user.dir}/#{args[0]}"
        unless File.exist? "#{client.user.dir}/#{args[1]}"
          self.copyFile args, client
          File.delete "#{client.user.dir}/#{args[0]}"
          return Constant::Success
        end
        response.status = Constant::PathError
        return Constant::Fail
      end
      response.status = Constant::UnknownFile
      Constant::Fail
    end

    private
    #
    # Method used with mkdir to create all the directories needed
    #
    def self.createIntermediateDirs path, userpath
      p = File.dirname path
      if p =~ /\//
        createIntermediateDirs p, userpath
      end
      unless Dir.exist? "#{userpath}/#{p}"
        Dir.mkdir "#{userpath}/#{p}", 0700
      end
    end

    #
    # Method used to copy a file in an other
    #
    def self.copyFile args, client
      f1 = File.new "#{client.user.dir}/#{args[0]}"
      f2 = File.new "#{client.user.dir}/#{args[1]}", 'w'
      f2.write f1.read
      f1.close
      f2.close
    end

    public
    #
    # hash acting as a dispatcher for the above methods
    #
    ShellCommands ||= {
      "Mkdir".to_sym    => Proc.new { |args, response, client| self.mkdir args, response, client },
      "Rmdir".to_sym    => Proc.new { |args, response, client| self.rmdir args, response, client },
      "Rm".to_sym       => Proc.new { |args, response, client| self.rm args, response, client },
      "Ls".to_sym       => Proc.new { |args, response, client| self.ls args, response, client },
      "Cp".to_sym       => Proc.new { |args, response, client| self.cp args, response, client },
      "Touch".to_sym    => Proc.new { |args, response, client| self.touch args, response, client },
      "Mv".to_sym       => Proc.new { |args, response, client| self.mv args, response, client }
    }
  end
end
