#!/usr/bin/env ruby

module Mine

  #
  # Class containing all the data and methods concerning a client
  #
  class Client
    include Protocol

    attr_accessor :userdb
    attr_reader :user, :socket, :authenticated, :remoteHost, :socketType, :userdir

    # Class variable containing all the connected clients
    @@clients = []

    #
    # Constructor takes the socket the remote host adress the directory where server files are stored and the socket type TCP or WebSocket
    #
    def initialize sock, remoteHost, userdir, socketType
      @authenticated = false
      @user = nil
      @userdb = nil
      @@clients << self
      @socket = sock
      @remoteHost = remoteHost
      @socketType = socketType
      @userdir = userdir
    end

    #
    # Method called when the user is authenticated
    #
    def user= user
      @user = user
      if @user
        @authenticated = true
      else
        @authenticated = false
      end
    end

    #
    # Method to call when a client deisconnect or when the server quits
    #
    def exit exitType = :signalCatch
      @@clients.delete self
      if exitType == :signalCatch
        Log::Client.log "Sending exit message"
        @socket.write "QUIT={}"
        Log::Client.log "Sent"
      elsif exitType == :clientQuit
        Log::Client.log "Client quit"
      else
        Log::Client.log "Doing what we can do"
      end
      @socket.close
    end

    #
    # getter
    #
    def self.clients
      @@clients
    end

    #
    # Method called whenever the client gets data
    #
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
    # request array containing all request type
    Requests ||= [
                  Authenticate = "AUTHENTICATE",
                  Signup = "SIGNUP",
                  Exec = "EXEC",
                  Insert = "INSERT",
                  Backspace = "BACKSPACE",
                  Delete = "DELETE",
                  Move = "MOVE",
                  Load = "LOAD",
                  Shell = "SHELL"
                 ]
    #
    # is the request known or not ?
    #
    def unknownRequest? request, response
      unless Requests.index request
        Log::Client.error "Unknown request"
        response.status = Constant::UnknownRequest
        return true
      end
      false
    end

    #
    # is the request invalid ?
    #
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
