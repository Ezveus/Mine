#!/usr/bin/env ruby

load 'server/Constant.rb'

class Response
  attr_accessor :status
  
  def initialize
    @status = Constant::Ok
  end
end
