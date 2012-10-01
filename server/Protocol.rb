#!/usr/bin/env ruby

module Protocol
  Requests = [Authenticate = "AUTHENTICATE",
              Signup = "SIGNUP"]

  def self.authenticate postContent, response
    puts "Here should JSON argument be parsed"
    puts "NOT Parsing #{postContent.split('=')[1]}"
    Constant::Success
  end

  def self.signup postContent, response
    puts "Here should JSON argument be parsed"
    puts "NOT Parsing #{postContent.split('=')[1]}"
    Constant::Success
  end

  Commands = {Authenticate.to_sym => Proc.new { |postContent, response| self.authenticate postContent, response },
    Signup.to_sym => Proc.new { |postContent, response| self.signup postContent, response }
  }
end
