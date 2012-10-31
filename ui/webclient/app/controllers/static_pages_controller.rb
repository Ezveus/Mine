class StaticPagesController < ApplicationController
  def home
    @active = :home
  end

  # def help
  #   @title = "Help"
  # end

  def signup
    @title = "Signup"
    @active = :signup
  end

  def about
    @title = "About"
    @active = :about
  end

  def contact
    @title = "Contact"
    @active = :contact
  end
end
