#!/usr/bin/env ruby

require 'eventmachine'
require 'em-websocket'

load 'server/Log.rb'

class WSClient < EventMachine::WebSocket::Connection
  def onOpen
    Log::WSClient.log "Connection from a client"
    self.send "ping"
  end

  def onClose
    Log::WSClient.log "Connection closed"
  end

  def onMessage msg
    Log::WSClient.log "Received message"
    self.send "pong"
  end

  def onError error
    if error.kind_of? EM::WebSocket::WebSocketError
      Log::WSClient.error "#{error}"
    end
  end

  def initialize *args
    super *args

    @onopen = Proc.new do self.onOpen end
    @onclose = Proc.new do self.onClose end
    @onmessage = Proc.new do |msg| self.onMessage msg end
    @onerror = Proc.new do |error| self.onError error end
  end
end
