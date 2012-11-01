class UsersController < ApplicationController
  def new
    @title = "Signup"
    @active = :signup
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @title = "#{@user.name}"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      1
    else
      @titre = "Inscription"
      render 'new'
    end
  end
end
