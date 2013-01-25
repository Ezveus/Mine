#!/usr/bin/env ruby

require 'json'
require 'base64'

load "server/User.rb"
load "server/Socket.rb"
load "server/Log.rb"
load "server/Exec.rb"

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
        response .status = Constant::ForbiddenAction
        return Constant::Fail
      end
      Exec::ExecCommands[object["command"].to_sym].call buffer, object["args"], response, client
      Constant::Success
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
      direction = object["direction"]
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
      path = object["path"]
      fileName = File.basename path
      socket = Mine::Socket.create client.remoteHost, object["port"], client.socketType
      fileContent = socket.read object["size"]
      Log::Client.log "Creating the frame : #{path}"
      uuid = client.user.addFrame path, fileName, fileContent, {}, false, object["line"]
      response.info["uuid"] = uuid
      Constant::Success
    end

    # Commands ||= {
    #   Authenticate.to_sym => Proc.new { |jsonRqst, response, client| self.authenticate jsonRqst, response, client },
    #   Signup.to_sym => Proc.new { |jsonRqst, response, client| self.signup jsonRqst, response, client },
    #   Exec.to_sym => Proc.new { |jsonRqst, response, client| self.exec jsonRqst, response, client },
    #   Insert.to_sym => Proc.new { |jsonRqst, response, client| self.insert jsonRqst, response, client },
    #   Backspace.to_sym => Proc.new { |jsonRqst, response, client| self.backspace jsonRqst, response, client },
    #   Delete.to_sym => Proc.new { |jsonRqst, response, client| self.delete jsonRqst, response, client },
    #   Move.to_sym => Proc.new { |jsonRqst, response, client| self.move jsonRqst, response, client },
    #   Load.to_sym => Proc.new { |jsonRqst, response, client| self.load jsonRqst, response, client }
    # }

    Commands ||= {
      "AUTHENTICATE".to_sym => Proc.new { |jsonRqst, response, client| self.authenticate jsonRqst, response, client },
      "SIGNUP".to_sym => Proc.new { |jsonRqst, response, client| self.signup jsonRqst, response, client },
      "EXEC".to_sym => Proc.new { |jsonRqst, response, client| self.exec jsonRqst, response, client },
      "INSERT".to_sym => Proc.new { |jsonRqst, response, client| self.insert jsonRqst, response, client },
      "BACKSPACE".to_sym => Proc.new { |jsonRqst, response, client| self.backspace jsonRqst, response, client },
      "DELETE".to_sym => Proc.new { |jsonRqst, response, client| self.delete jsonRqst, response, client },
      "MOVE".to_sym => Proc.new { |jsonRqst, response, client| self.move jsonRqst, response, client },
      "LOAD".to_sym => Proc.new { |jsonRqst, response, client| self.load jsonRqst, response, client }
    }

  end
end
