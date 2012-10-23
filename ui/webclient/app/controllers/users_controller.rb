class UsersController < ApplicationController
  def new
    @title = "Signup"
    @active = :signup
  end
end
