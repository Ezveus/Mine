#!/usr/bin/env ruby

load "Buffer.rb"
load "Cursor.rb"

class Frame
  attr_accessor :buffer, :cursor

  def initialize buffer, cursor
    @buffer = buffer
    @cursor = cursor
  end
end
