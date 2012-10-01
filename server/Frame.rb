#!/usr/bin/env ruby

load "server/Buffer.rb"
load "server/Cursor.rb"

class Frame
  attr_accessor :buffer, :cursor

  def initialize buffer, cursor
    @buffer = buffer
    @cursor = cursor
  end
end
