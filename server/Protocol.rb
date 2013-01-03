#!/usr/bin/env ruby

require 'json'

load "server/User.rb"
load "server/Log.rb"

module Mine
  module Protocol
    Requests ||= [
                  Authenticate = "AUTHENTICATE",
                  Signup = "SIGNUP",
                  Exec = "EXEC",
                  Insert = "INSERT",
                  Backspace = "BACKSPACE",
                  Delete = "DELETE",
                  Move = "MOVE",
                  File = "FILE"
                 ]

    def self.authenticate jsonRqst, response, client
      if client.authenticated
        Log::Client.error "#{client.user} already logged"
        response.status = Constant::AlreadyLogged
        return Constant::Fail
      end
      Log::Client.debug "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "#{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
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
      client.user = User.new name, client.userdb, client
      Log::Client.log "User logged : #{client.user.userInfo}"
      Constant::Success
    end

    def self.signup jsonRqst, response, client
      Log::Client.debug "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "#{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
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
      Log::Client.info "Here should JSON argument be parsed"
      Log::Client.info "NOT Parsing #{jsonRqst}"
      Constant::Success
    end

    def self.insert jsonRqst, response, client
      Log::Client.debug "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "Error : #{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      if client.user.nil?
        Log::Client.error "Insert : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object[buffer]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      text = object[text]
      client.user.insert buffer, text
      Log::Client.debug "Inserted #{text} in #{buffer}"
      Constant::Success
    end

    def self.backspace jsonRqst, response, client
      Log::Client.debug "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "Error : #{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      if client.user.nil?
        Log::Client.error "Backspace : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object[buffer]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      number = object[number]
      client.user.backspace buffer, number
      Log::Client.debug "Erased #{number} characters in #{buffer}"
      Constant::Success
    end

    def self.delete jsonRqst, response, client
      Log::Client.log "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "Error : #{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      if client.user.nil?
        Log::Client.error "Delete : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object[buffer]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      number = object[number]
      client.user.delete buffer, number
      Constant::Success
    end

    def self.move jsonRqst, response, client
      Log::Client.log "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "Error : #{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      if client.user.nil?
        Log::Client.error "Move : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      buffer = client.user.findBuffer object[buffer]
      if buffer.nil?
        Log::Client.error "Unknown buffer"
        response.status = Constant::UnknownBuffer
        return Constant::Fail
      end
      direction = object[direction]
      number = object[number]
      client.user.moveCursor buffer, direction, number
      Constant::Success
    end

    def self.file jsonRqst, response, client
      Log::Client.log "Parsing #{jsonRqst}"
      object = {}
      begin
        object = JSON.parse jsonRqst
      rescue JSON::ParserError => error
        Log::Client.error "Error : #{error}"
        response.status = Constant::JSONParserError
        return Constant::Fail
      end
      if client.user.nil?
        Log::Client.error "File : not logged"
        response.status = Constant::ForbiddenAction
        return Constant::Fail
      end
      path = object[path]
      fileName = File.basename path
      Log::Client.log "not creating the frame"
      # Socket.new
      # client.user.addFrame path, fileName, fileContent, {}, false, object[line]
      Constant::Success
    end

    Commands ||= {
      Authenticate.to_sym => Proc.new { |jsonRqst, response, client| self.authenticate jsonRqst, response, client },
      Signup.to_sym => Proc.new { |jsonRqst, response, client| self.signup jsonRqst, response, client },
      Exec.to_sym => Proc.new { |jsonRqst, response, client| self.exec jsonRqst, response, client },
      Insert.to_sym => Proc.new { |jsonRqst, response, client| self.insert jsonRqst, response, client },
      Backspace.to_sym => Proc.new { |jsonRqst, response, client| self.backspace jsonRqst, response, client },
      Delete.to_sym => Proc.new { |jsonRqst, response, client| self.delete jsonRqst, response, client },
      Move.to_sym => Proc.new { |jsonRqst, response, client| self.move jsonRqst, response, client },
      File.to_sym => Proc.new { |jsonRqst, response, client| self.file jsonRqst, response, client }
    }
  end
end
