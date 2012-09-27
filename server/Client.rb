#!/usr/bin/env ruby

class Client
  def initialize authenticated, user
    @authenticated = authenticated
    @user = user
    @users = []
  end
end
