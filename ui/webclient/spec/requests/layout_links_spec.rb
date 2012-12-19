# -*- coding: utf-8 -*-
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

  describe "Check Links" do
    it "checks the links" do
      visit root_path
      click_link "About"
      response.should have_selector('title',
                                    :content => aboutTitle)
      # click_link "Help"
      # response.should have_selector('title',
      #                               :content => helpTitle)
      click_link "Contact"
      response.should have_selector('title',
                                    :content => contactTitle)
      click_link "Home"
      response.should have_selector('title',
                                    :content => rootTitle)
      click_link "Signup"
      response.should have_selector('title',
                                    :content => signupTitle)
      click_link "Signin"
      response.should have_selector('title',
                                    :content => signinTitle)
    end
  end
end
