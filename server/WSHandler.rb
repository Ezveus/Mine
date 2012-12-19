#!/usr/bin/env ruby

require 'json'
require 'eventmachine'
require 'em-websocket'
# require 'minep'

load 'server/Log.rb'

class WSClient < EventMachine::WebSocket::Connection
  # def transfer toTransfer
  #   type = toTransfer.split('=')[0].downcase.to_sym
  #   opts = {}
  #   begin
  #     opts = JSON.parse toTransfer.split('=')[1]
  #   rescue JSON::ParserError => error
  #     Log::WSClient.error "#{error}"
  #     return Constant::JSONParserError
  #   end
  #   keys = opts.each_key
  #   keysyms = []
  #   keys.each do |key|
  #     @opts[key.to_sym] = opts[key]
  #   end
  #   begin
  #     return MINEP.send type, @opts
  #   rescue MINEP::ArgumentsError => e
  #     Log::WSClient.error "#{e}"
  #     return Constant::MINEPSendError
  #   end
  #   Constant::Ok
  # end

  def onOpen
    Log::WSClient.log "Connection from a client"
    Log::WSClient.log "Sending PING"
    self.send "PING"
  end

  def onClose
    Log::WSClient.log "Connection closed"
  end

  def onMessage msg
    if msg == "PONG"
      Log::WSClient.log "Received PONG"
      @pingpong = true
    end
    if @pingpong
      request = msg.split('->')[0]
      if request == 'TRANSFER'
        Log::WSClient.log "Received TRANSFER"
        # retCode = self.transfer msg.split('->')[1]
        retCode = 0
        self.send "CODE->#{retCode}"
      elsif request == 'DISCONNECT'
        Log::WSClient.log "Received DISCONNECT"
        self.send 'DISCONNECT'
      else
        Log::WSClient.log "Received unknown request" if request != 'PONG'
        self.send "WAIT_REQUEST"
      end
    end
  end

  def onError error
    if error.kind_of? EM::WebSocket::WebSocketError
      Log::WSClient.error "#{error}"
    end
  end

  def initialize opts
    super

    @onopen = Proc.new do self.onOpen end
    @onclose = Proc.new do self.onClose end
    @onmessage = Proc.new do |msg| self.onMessage msg end
    @onerror = Proc.new do |error| self.onError error end
    @pingpong = false
    @opts = opts
  end
end
