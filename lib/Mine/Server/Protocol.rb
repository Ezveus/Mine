#!/usr/bin/env ruby

module Mine
  module Protocol

    #
    # method that checks common errors for the requests
    #
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

    #
    # method called when an AUTHENTICATE request is received
    #
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
      userdb = UserInfos.selectUser name
      unless userdb
        Log::Client.error "Unknown user"
        response.status = Constant::UnknownUser
        return Constant::Fail
      end
      unless userdb.matchPass pass
        Log::Client.error "Unknown user"
        response.status = Constant::UnknownUser
        return Constant::Fail
      end
      client.userdb = userdb
      client.user = User.getInstance name, client
      Log::Client.log "User logged : #{client.user.userInfo}"
      Constant::Success
    end

    #
    # Method called when a SIGNUP request is received
    #
    def self.signup jsonRqst, response, client
      if client.authenticated
        Log::Client.error "#{client.user} already logged"
        response.status = Constant::AlreadyLogged
        return Constant::Fail
      end
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
      userdb = UserInfos.addUser name, pass, email, website
      unless userdb
        Log::Client.error "User #{name} can't be added"
        response.status = Constant::BadRegistration
        return Constant::Fail
      end
      client.userdb = userdb
      client.user = User.getInstance name, client
      Log::Client.log "New user : #{userdb}"
      Constant::Success
    end

    #
    # Method called when an EXEC request is received
    #
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

    #
    # Method called when an INSERT request is received
    #
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

    #
    # Method called when a BACKSPACE request is received
    #
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

    #
    # Method called when a DELETE request is received
    #
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

    #
    # Method called when a MOVE request is received
    #
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

    #
    # Method called when a LOAD request is received
    #
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
            when :down then self.downloadFile object, response, client, uuid
            else response.status = Constant::UnvalidRequest; Constant::Fail
            end
      return ret if ret == Constant::Fail
      puts uuid
      response.info["uuid"] = uuid
      Constant::Success
    end

    #
    # Method called when the parameter of a LOAD request is up
    #
    def self.uploadFile object, response, client, uuid
      path = object["path"]
      fileName = File.basename path
      socket = Mine::Socket.create client.remoteHost, object["port"], client.socketType
      fileContent = socket.read object["size"]
      Log::Client.log "Creating the frame : #{path}"
      uuid.replace client.user.addFrame path, fileName, fileContent, {}, false, object["line"]
      Constant::Success
    end

    #
    # Method called when the parameter of a LOAD request id down
    #
    def self.downloadFile object, response, client, uuid
      path = "#{client.user.dir}/#{object["path"]}"
      unless File.exist? path
        response.status = Constant::UnknownFile
        return Constant::Fail
      end
      begin
        if type == :tcp
          server = Socket.create client.remoteHost, object["port"], :tcps
        elsif type == :wsp
          server = Socket.create client.remoteHost, object["port"], :wsps
        end
      rescue
        Log::Client.error "Cannot create Server with port : #{object["port"]}"
        response.status = Constant::PortAlreadyUsed
        return Constant::Fail
      end
      file = File.new path
      content = file.read
      file.close
      Log::Client.log "Creating the frame : #{path}"
      uuid.replace client.user.addFrame path, File.basename(path), content, {}, true, object["line"]
      server = nil
      type = client.socketType
      socket = server.accept
      socket.write content
      socket.close
      server.close
      Constant::Success
    end

    #
    # Method called when a SHELL request is received
    #
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

    # hash acting as a dispatcher for the above methods
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
