#!/usr/bin/env ruby

module Mine
  class Client
    include Protocol

    attr_accessor :userdb
    attr_reader :user, :socket, :authenticated, :remoteHost, :socketType, :userdir

    @@clients = []

    def initialize sock, remoteHost, userdir, socketType
      @authenticated = false
      @user = nil
      @userdb = Userdb.new
      @@clients << self
      @socket = sock
      @remoteHost = remoteHost
      @socketType = socketType
      @userdir = userdir
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
      buffer = buffer.strip
      response = Response.new
      request = buffer.split '=', 2
      return Constant::Fail if unvalidRequest? buffer, response
      return Constant::Fail if unknownRequest? request[0], response
      @user.lastClient = self unless @user.nil?
      Commands[request[0].to_sym].call request[1], response, self
      @socket.write "RESPONSE=#{JSON.dump response}"
    end

    private
    Requests ||= [
                  Authenticate = "AUTHENTICATE",
                  Signup = "SIGNUP",
                  Exec = "EXEC",
                  Insert = "INSERT",
                  Backspace = "BACKSPACE",
                  Delete = "DELETE",
                  Move = "MOVE",
                  Load = "LOAD"
                 ]

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
end
