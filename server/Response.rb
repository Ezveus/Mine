#!/usr/bin/env ruby

load 'server/Constant.rb'

module Mine
  class Response
    attr_accessor :status
  
    def initialize
      @status = Constant::Ok
    end
  end
end
