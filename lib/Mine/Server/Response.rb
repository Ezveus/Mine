#!/usr/bin/env ruby

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
