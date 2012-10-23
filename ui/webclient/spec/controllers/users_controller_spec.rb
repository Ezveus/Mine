require 'spec_helper'

rootTitle = "Mine Is Not Emacs : Embedded Client"
signupTitle = "#{rootTitle} - Signup"

describe UsersController do
  render_views

  describe "GET 'signup'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "'signup' title" do
    it "should be #{signupTitle}" do
      get 'new'
      response.should have_selector("title",
                                    :content => signupTitle)
    end
  end
  
end
