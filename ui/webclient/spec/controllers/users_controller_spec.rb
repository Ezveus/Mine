require 'spec_helper'

rootTitle = "Mine Is Not Emacs : Embedded Client"
newTitle = "#{rootTitle} - Signin"
ezveusUserTitle = "#{rootTitle} - Ezveus"
ezveusUserPar = "Ezveus # <@ : ciappam@gmail.com, web : http://localhost:3000>"

describe UsersController do
  render_views

  before :each do
    @user = FactoryGirl.create :user
  end

  describe "New tests" do
    before :each do
      get :new
    end
    
    it "returns http success" do
      response.should be_success
    end
    
    it "should have #{newTitle} as title" do
      response.should have_selector("title",
                                    :content => newTitle)
    end
  end

  describe "Show tests" do
    before :each do
      get :show, :id => @user
    end

    it "should find the created user" do
      response.should be_success
    end

    it "should match the created user with the one in the database" do
      assigns(:user).should == @user
    end

    it "should have title #{ezveusUserTitle}" do
      response.should have_selector("title",
                                    :content => ezveusUserTitle)
    end

    it "should have paragraph #{ezveusUserPar}" do
      response.should have_selector("p",
                                    :content => ezveusUserPar)
    end
  end
end
