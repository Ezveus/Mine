#!/usr/bin/env ruby

load 'server/Constant.rb'

module Mine
  class Response
    attr_accessor :status, :id, :info
  
    def initialize
      @status = Constant::Ok
      @id = ""
      @info = {}
    end
  end
end
