#!/usr/bin/env ruby

load "server/Constant.rb"
load "server/Protocol.rb"
load "server/Userdb.rb"
load "server/Log.rb"
load "server/Response.rb"

class Client
  include Protocol

  attr_accessor :userdb
  attr_reader :user

  @@clients = []

  def initialize sock
    @authenticated = false
    @user = nil
    @userdb = Userdb.new
    @@clients << self
    @socket = sock
  end

  def user= user
    @user = user
    if @user
      @authenticated = true
    else
      @authenticated = false
    end
  end

  def exit exitType = :signalCatch
    @socket.close
    @@clients.delete self
    if exitType == :signalCatch
      Log::Client.log "Sending exit message"
      Log::Client.log "Sent"
    else
      Log::Client.log "Doing what we can do"
    end
  end

  def self.clients
    @@clients
  end

  def readAndProcessRequest
    buffer = @socket.readpartial Constant::RequestSize
    response = Response.new
    request = buffer.split '='
    return Constant::Fail if unvalidRequest? buffer, response
    return Constant::Fail if unknownRequest? request[0], response
    Commands[request[0].to_sym].call request[1], response, self
  end

  private
  def unknownRequest? request, response
    unless Requests.index request
      Log::Client.error "Unknown request"
      response.status = Constant::UnknownRequest
      return true
    end
    false
  end

  def unvalidRequest? msg, response
    unless (msg =~ /.+={.*}/) == 0
      Log::Client.error "Unvalid request : bad body"
      response.status = Constant::UnvalidRequest
      return true
    end
    false
  end
end
