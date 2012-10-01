#!/usr/bin/env ruby

load "server/Userdb.rb"
load "server/Frame.rb"

class User
  attr_accessor :cmdHistory, :killRing

  def initialize username, userdb
    @clients = []
    @cmdHistory = []
    @killRing = ""
    @frames = []
    @userInfo = userdb.selectUser username
  end
end
