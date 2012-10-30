class UsersController < ApplicationController
  def new
    @title = "Signin"
    @active = :signin
  end

  def show
    @user = User.find(params[:id])
    @title = "#{@user.name}"
  end
end
