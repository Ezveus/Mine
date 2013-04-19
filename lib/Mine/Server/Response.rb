#!/usr/bin/env ruby

module Mine
  class Response
    attr_accessor :status, :id, :info

    #
    # Creates a new RESPONSE request
    #  
    def initialize
      @status = Constant::Ok
      @id = ""
      @info = {}
    end
  end
end
