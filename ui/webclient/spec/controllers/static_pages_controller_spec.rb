require 'spec_helper'

rootTitle = "Mine Is Not Emacs : Embedded Client"
# helpTitle = "#{rootTitle} - Help"
signinTitle = "#{rootTitle} - Signin"
aboutTitle = "#{rootTitle} - About"
contactTitle = "#{rootTitle} - Contact"

describe StaticPagesController do
  render_views

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
  end

  describe "'home' title" do
    it "should be #{rootTitle}" do
      get 'home'
      response.should have_selector("title",
                                    :content => rootTitle)
    end
  end

  # describe "GET 'help'" do
  #   it "returns http success" do
  #     get 'help'
  #     response.should be_success
  #   end
  # end

  # describe "'help' title" do
  #   it "should be #{helpTitle}" do
  #     get 'help'
  #     response.should have_selector("title",
  #                                   :content => helpTitle)
  #   end
  # end

  describe "GET 'signin'" do
    it "returns http success" do
      get 'signin'
      response.should be_success
    end
  end

  describe "'signin' title" do
    it "should be #{signinTitle}" do
      get 'signin'
      response.should have_selector("title",
                                    :content => signinTitle)
    end
  end

  describe "GET 'about'" do
    it "returns http success" do
      get 'about'
      response.should be_success
    end
  end

  describe "'about' title" do
    it "should be #{aboutTitle}" do
      get 'about'
      response.should have_selector("title",
                                    :content => aboutTitle)
    end
  end

  describe "GET 'contact'" do
    it "returns http success" do
      get 'contact'
      response.should be_success
    end
  end

  describe "'contact' title" do
    it "should be #{contactTitle}" do
      get 'contact'
      response.should have_selector("title",
                                    :content => contactTitle)
    end
  end
end