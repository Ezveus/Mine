#!/usr/bin/env ruby

module Mine
  module Protocol

    def self.getObjectFromJSON jsonRqst, response
      Log::Client.debug "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "#{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      id = object["id"]
      unless id
        Log::Client.error "No request ID"
        response.status = Constant::MissingIDError
        return nil
      end
      response.id = object["id"]
      object
    end

    def self.authenticate jsonRqst, response, client
      if client.authenticated
        Log::Client.error "#{client.user} already logged"
        response.status = Constant::AlreadyLogged
        return Constant::Fail
      end
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      name = object["name"]
      pass = object["pass"]
      unless name and pass
        Log::Client.error "Field(s) name and/or pass can't be found"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      unless client.userdb.matchPass name, pass
        Log::Client.error "Unknown user"
        response.status = Constant::UnknownUser
        return Constant::Fail
      end
      client.user = User.getInstance name, client.userdb, client
      Log::Client.log "User logged : #{client.user.userInfo}"
      Constant::Success
    end

    def self.signup jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      name = object["name"]
      pass = object["pass"]
      email = object["email"]
      website = object["website"]
      unless name and pass and email
        Log::Client.error "Field(s) name and/or pass and/or email can't be found"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      unless client.userdb.addUser name, pass, email, website
        client.userdb.errors.each do |err|
          Log::Client.error err
        end
        response.status = Constant::BadRegistration
        return Constant::Fail
      end
      Log::Client.log "New user : #{client.userdb.selectUser name}"
      Constant::Success
    end

    def self.exec jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "Exec : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object["buffer"]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      if Exec::ExecCommands[object["command"].to_sym].nil?
        Log::Client.error "Unknown exec command"
        response.status = Constant::UnknownCommand
        return Constant::Fail
      end
      Exec::ExecCommands[object["command"].to_sym].call buffer, object["args"], response, client
    end

    def self.insert jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "Insert : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object["buffer"]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      text = Base64.decode64 object["text"]
      client.user.insert buffer, text
      Log::Client.debug "Inserted #{text} in #{buffer}"
      Constant::Success
    end

    def self.backspace jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "Backspace : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object["buffer"]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      number = object["number"]
      client.user.backspace buffer, number
      Log::Client.debug "Erased #{number} characters in #{buffer}"
      Constant::Success
    end

    def self.delete jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "Delete : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object["buffer"]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      number = object["number"]
      client.user.delete buffer, number
      Constant::Success
    end

    def self.move jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "Move : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object["buffer"]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      direction = object["direction"].to_sym
      number = object["number"]
      client.user.moveCursor buffer, direction, number
      Constant::Success
    end

    def self.load jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "File : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      uuid = ""
      ret = case object["type"].to_sym
            when :up then self.uploadFile object, response, client, uuid
            when :down then self.downloadFile object, reponse, client, uuid
            else response.status = Constant::UnvalidRequest; Constant::Fail
            end
      return ret if ret == Constant::Fail
      puts uuid
      response.info["uuid"] = uuid
      Constant::Success
    end

    def self.uploadFile object, response, client, uuid
      path = object["path"]
      fileName = File.basename path
      socket = Mine::Socket.create client.remoteHost, object["port"], client.socketType
      fileContent = socket.read object["size"]
      Log::Client.log "Creating the frame : #{path}"
      uuid.replace client.user.addFrame path, fileName, fileContent, {}, false, object["line"]
      Constant::Success
    end

    def self.downloadFile object, response, client, uuid
      path = object["path"]
      unless File.exist? path
        response.status = Constant::UnknownFile
        return Constant::Fail
      end
      file = File.new path
      content = file.read
      file.close
      # create the frame
      server = nil
      if type == :tcp
        server = Socket.create client.remoteHost, object["port"], :tcps
      elsif type == :wsp
        server = Socket.create client.remoteHost, object["port"], :wsps
      end
      socket = server.accept
      socket.write content
      socket.shutdown :RDWR
      socket.close
      server.close
    end

    def self.shell jsonRqst, response, client
      object = getObjectFromJSON jsonRqst, response
      return Constant::Fail if object.nil?
      unless client.authenticated
        Log::Client.error "File : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      if Shell::ShellCommands[object["command"].to_sym].nil?
        Log::Client.error "Unknown shell command"
        response.status = Constant::UnknownCommand
        return Constant::Fail
      end
      Shell::ShellCommands[object["command"].to_sym].call object["args"], response, client
    end

    Commands ||= {
      "AUTHENTICATE".to_sym => Proc.new { |jsonRqst, response, client| self.authenticate jsonRqst, response, client },
      "SIGNUP".to_sym => Proc.new { |jsonRqst, response, client| self.signup jsonRqst, response, client },
      "EXEC".to_sym => Proc.new { |jsonRqst, response, client| self.exec jsonRqst, response, client },
      "INSERT".to_sym => Proc.new { |jsonRqst, response, client| self.insert jsonRqst, response, client },
      "BACKSPACE".to_sym => Proc.new { |jsonRqst, response, client| self.backspace jsonRqst, response, client },
      "DELETE".to_sym => Proc.new { |jsonRqst, response, client| self.delete jsonRqst, response, client },
      "MOVE".to_sym => Proc.new { |jsonRqst, response, client| self.move jsonRqst, response, client },
      "LOAD".to_sym => Proc.new { |jsonRqst, response, client| self.load jsonRqst, response, client },
      "SHELL".to_sym => Proc.new { |jsonRqst, response, client| self.shell jsonRqst, response, client }
    }

  end
end
