#!/usr/bin/env ruby

load "Userdb.rb"
load "Frame.rb"

class User
  attr_accessor :cmdHistory, :killRing

  def initialize username
    @cmdHistory = []
    @killRing = ""
    @frames = []
    @userInfo = Userdb::UserInfos.new username
  end
end
