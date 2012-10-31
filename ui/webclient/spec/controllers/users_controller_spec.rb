require 'spec_helper'

rootTitle = "Mine Is Not Emacs : Embedded Client"
newTitle = "#{rootTitle} - Signin"

describe UsersController do
  render_views

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end

    it "should have #{newTitle} as title" do
      get 'new'
      response.should have_selector("title", :content => newTitle)
    end
  end

end
