module Mine
  class Code
    attr_accessor :code

    def initialize
      @code = 0
    end
  end

  class WSConnection < EM::WebSocketClient
    def onError err # errback
    end

    def onOpen # callback
      self.send_msg "PONG"
    end

    def onRead msg # stream
      request = msg.split('=')[0]
      if request == "WAIT_REQUEST"
        unless @user.website.nil?
          self.send_msg "SIGNUP={\"name\":\"#{@user.name}\",\"pass\":\"#{@user.password}\",\"email\":\"#{@user.email}\",\"website\":\"#{@user.website}\"}"
        else
          self.send_msg "SIGNUP={\"name\":\"#{@user.name}\",\"pass\":\"#{@user.password}\",\"email\":\"#{@user.email}\"}"
        end
      elsif request == "CODE"
        @errCode.code = msg.split('=')[1].to_i
        self.send_msg "DISCONNECT"
      elsif request == "DISCONNECT"
        EM::stop_event_loop
      end
    end

    def onDisconnection # disconnect
      EM::stop_event_loop
    end

    def initialize user, errCode
      super

      @user = user
      @errCode = errCode
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
    if ret and @user.save
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
    errCode = Mine::Code.new
    EM.run do
      EM.connect "localhost", wsport, Mine::WSConnection, @user, errCode do |c|
        c.url = "ws://#{"localhost"}:#{wsport}"
      end
    end
    errCode.code
  end
end
