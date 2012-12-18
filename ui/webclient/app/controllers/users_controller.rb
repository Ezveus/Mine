module Mine
  class WSConnection < EM::WebSocketClient
    def onError err # errback
      puts "Error : #{err}"
    end

    def onOpen # callback
      puts "Sending PONG"
      self.send_msg "PONG"
    end

    def onRead msg # stream
      request = msg.split('->')[0]
      puts "Request : #{request}"
      puts "Msg : #{msg}"
      if request == "WAIT_REQUEST"
        puts "Was a \"WAIT_REQUEST\""
        unless @user.website.nil?
          self.send_msg "TRANSFER->SIGNUP={\"name\":\"#{@user.name}\",\"pass\":\"#{@user.password}\",\"email\":\"#{@user.email}\",\"website\":\"#{@user.website}\"}"
        else
          self.send_msg "TRANSFER->SIGNUP={\"name\":\"#{@user.name}\",\"pass\":\"#{@user.password}\",\"email\":\"#{@user.email}\"}"
        end
      elsif request == "CODE"
        errCode = msg.split('->')[1].to_i
        self.send_msg "DISCONNECT"
      elsif request == "DISCONNECT"
        EM::stop_event_loop
      end
    end

    def onDisconnection # disconnect
      puts "Disconnected"
      EM::stop_event_loop
    end

    def initialize user
      super

      @user = user
      self.callback do
        self.onOpen
      end
      self.stream do |msg|
        self.onRead msg
      end
      self.errback do |error|
        self.onError error
      end
      self.disconnect do
        self.onDisconnection
      end
    end
  end
end

class UsersController < ApplicationController
  def new
    @title = "Signup"
    @active = :signup
    @user = User.new
  end

  def show
    @user = User.find params[:id]
    @title = "#{@user.name}"
  end

  def create
    @title = "Creation"
    @user = User.new params[:user]
    ret = sendSignup getWSPort
    if ret = true and @user.save
      redirect_to @user
    else
      @title = "Signup"
      @active = :signup
      render 'new'
    end
  end

  def getWSPort
    File.new(Rails.root + ".port").read.split("|")[1]
  end

  def getPort
    File.new(Rails.root + ".port").read.split("|")[0]
  end

  def sendSignup wsport
    errCode = 0
    EventMachine.run do
      # ws = EventMachine::WebSocketClient.connect("ws://localhost:#{wsport}")
      EM.connect "localhost", wsport, Mine::WSConnection, @user
    end
    errCode
  end
end
