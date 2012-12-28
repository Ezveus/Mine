#!/usr/bin/env ruby

require 'json'

load "server/User.rb"
load "server/Log.rb"

module Mine
  module Protocol
    Requests ||= [
                  Authenticate = "AUTHENTICATE",
                  Signup = "SIGNUP",
                  Exec = "EXEC"
                 ]

    def self.authenticate jsonRqst, response, client
      if client.authenticated
        Log::Client.error "#{client.user} already logged"
        response.status = Constant::AlreadyLogged
        return Constant::Fail
      end
      Log::Client.log "Parsing #{jsonRqst}"
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
      Log::Client.log "Parsing #{jsonRqst}"
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
      Constant::Success
    end

    def self.exec jsonRqst, response, client
      Log::Client.info "Here should JSON argument be parsed"
      Log::Client.info "NOT Parsing #{jsonRqst}"
      Constant::Success
    end

    Commands ||= {
      Authenticate.to_sym => Proc.new { |jsonRqst, response, client| self.authenticate jsonRqst, response, client },
      Signup.to_sym => Proc.new { |jsonRqst, response, client| self.signup jsonRqst, response, client },
      Exec.to_sym => Proc.new { |jsonRqst, response, client| self.exec jsonRqst, response, client }
    }
  end
end
