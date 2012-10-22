require 'spec_helper'

rootTitle = "Mine Is Not Emacs : Embedded Client"
# helpTitle = "#{rootTitle} - Help"
signinTitle = "#{rootTitle} - Signin"
signupTitle = "#{rootTitle} - Signup"
aboutTitle = "#{rootTitle} - About"
contactTitle = "#{rootTitle} - Contact"

describe "LayoutLinks" do
  describe "GET /" do
    it "should be #{rootTitle}" do
      get '/'
      response.should have_selector('title',
                                    :content => rootTitle)
    end
  end

  # describe "GET /help" do
  #   it "should be #{helpTitle}" do
  #     get '/help'
  #     response.should have_selector('title',
  #                                   :content => helpTitle)
  #   end
  # end

  describe "GET /signin" do
    it "should be #{signinTitle}" do
      get '/signin'
      response.should have_selector('title',
                                    :content => signinTitle)
    end
  end

  describe "GET /signup" do
    it "should be #{signupTitle}" do
      get '/signup'
      response.should have_selector('title',
                                    :content => signupTitle)
    end
  end

  describe "GET /about" do
    it "should be #{aboutTitle}" do
      get '/about'
      response.should have_selector('title',
                                    :content => aboutTitle)
    end
  end

  describe "GET /contact" do
    it "should be #{contactTitle}" do
      get '/contact'
      response.should have_selector('title',
                                    :content => contactTitle)
    end
  end
end
