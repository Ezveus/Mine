require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com" }
  end

  it "should create a new instance with valids attributes" do
    User.create!(@attr)
  end
  describe "Name Tests" do
    it "should need a name" do
      bad_guy = User.new(@attr.merge(:name => ""))
      bad_guy.should_not be_valid
    end
  end

  describe "Email Tests" do
    it "should need a mail" do
      bad_guy = User.new(@attr.merge(:email => ""))
      bad_guy.should_not be_valid
    end
  end
end
