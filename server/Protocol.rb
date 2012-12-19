#!/usr/bin/env ruby

require 'json'

load "server/User.rb"
load "server/Log.rb"

module Protocol
  Requests = [
              Authenticate = "AUTHENTICATE",
              Signup = "SIGNUP",
              Exec = "EXEC"
             ]

  def self.authenticate postContent, response, client
    if client.user and client.user.authenticated
      Log::Client.error "#{client.user} already logged"
      response.status = Constant::AlreadyLogged
      return Constant::Fail
    end
    Log::Client.log "Parsing #{postContent.split('=')[1]}"
    object = {}
    begin
      object = JSON.parse postContent.split('=')[1]
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
    client.user = User.new name, client.userdb
    Log::Client.log "User logged : #{client.user.userInfo}"
    Constant::Success
  end

  def self.signup postContent, response, client
    Log::Client.log "Parsing #{postContent.split('=')[1]}"
    object = {}
    begin
      object = JSON.parse postContent.split('=')[1]
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

  def self.exec postContent, response, client
    Log::Client.info "Here should JSON argument be parsed"
    Log::Client.info "NOT Parsing #{postContent.split('=')[1]}"
    Constant::Success
  end

  def self.insert postContent, response, client
    puts "Parsing #{postContent.split('=')[1]}"
    object = {}
    begin
      object = JSON.parse postContent.split('=')[1]
    rescue JSON::ParserError => error
      $stderr.puts "Error : #{error}"
      response.status = Constant::JSONParserError
      return Constant::Fail
    end
    if client.user.nil?
      $stderr.puts "A client is trying to edit a buffer without a user logged in."
      response.status = Constant::ForbiddenAction
      return Constant::Fail
    end
    buffer = client.user.findBuffer object[buffer]
    if buffer.nil?
      $stderr.puts "Unknown buffer"
      response.status = Constant::UnknownBuffer
      return Constant::Fail
    end
    text = object[text]
    client.user.insert buffer, text
    Constant::Success
  end

  Commands = {
    Authenticate.to_sym => Proc.new { |postContent, response, client| self.authenticate postContent, response, client },
    Signup.to_sym => Proc.new { |postContent, response, client| self.signup postContent, response, client },
    Exec.to_sym => Proc.new { |postContent, response, client| self.exec postContent, response, client },
    Insert.to_sym => Proc.new { |postContent, response, client| self.insert postContent, response, client }
  }
end
