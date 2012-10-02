#!/usr/bin/env ruby

require 'json'

load "server/User.rb"

module Protocol
  Requests = [
              Authenticate = "AUTHENTICATE",
              Signup = "SIGNUP",
              Minibuffer = "MINIBUFFER"
             ]

  def self.authenticate postContent, response, client
    if client.user and client.user.authenticated
      $stderr.puts "Error : #{client.user} already logged"
      response.status = Constant::AlreadyLogged
      return Constant::Fail
    end
    puts "Parsing #{postContent.split('=')[1]}"
    object = {}
    begin
      object = JSON.parse postContent.split('=')[1]
    rescue JSON::ParserError => error
      $stderr.puts "Error : #{error}"
      response.status = Constant::JSONParserError
      return Constant::Fail
    end
    name = object["name"]
    pass = object["pass"]
    unless name and pass
      $stderr.puts "Error : Field(s) name and/or pass can't be found"
      response.status = Constant::JSONParserError
      return Constant::Fail
    end
    unless client.userdb.matchPass name, pass
      $stderr.puts "Error : Unknown user"
      response.status = Constant::UnknownUser
      return Constant::Fail
    end
    client.user = User.new name, client.userdb
    puts "User logged : #{client.user.userInfo}"
    Constant::Success
  end

  def self.signup postContent, response, args
    userdb = args[0]
    puts "Here should JSON argument be parsed"
    puts "NOT Parsing #{postContent.split('=')[1]}"
    Constant::Success
  end

  def self.minibuffer postContent, response
    puts "Here should JSON argument be parsed"
    puts "NOT Parsing #{postContent.split('=')[1]}"
    Constant::Success
  end

  Commands = {
    Authenticate.to_sym => Proc.new { |postContent, response, client| self.authenticate postContent, response, client },
    Signup.to_sym => Proc.new { |postContent, response, args| self.signup postContent, response, args }
  }
end
