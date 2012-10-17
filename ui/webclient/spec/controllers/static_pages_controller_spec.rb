require 'spec_helper'

describe StaticPagesController do
  render_views

  homeTitle = "Mine Is Not Emacs : Embedded Client"

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
  end

  describe "'home' title" do
    it "should be #{homeTitle}" do
      get 'home'
      response.should have_selector("title",
                                    :content => homeTitle)
    end
  end
end
