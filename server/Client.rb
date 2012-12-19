#!/usr/bin/env ruby

load "server/Constant.rb"
load "server/Protocol.rb"
load "server/Userdb.rb"
load "server/Log.rb"

class Client < EM::Connection
  include Protocol

  attr_accessor :userdb
  attr_reader :user

  @@clients = []

  def initialize

    @authenticated = false
    @user = nil
    @userdb = Userdb.new
    @@clients << self
  end

  def user= user
    @user = user
    @authenticated = true if @user
    @authenticated = false unless @user
  end

  def exit exitType
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

  def unknownRequest? request, response
    unless Requests.index request
      Log::Client.error "Unknown request"
      response.status = Constant::UnknownRequest
      return true
    end
    false
  end
end
