# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  pass       :string(255)
#  email      :string(255)
#  website    :string(255)
#  isAdmin    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :pass => "pass",
      :email => "user@example.com"
    }
  end

  it "should create a new instance with valide attributes" do
    User.create!(@attr)
  end

  it "should need a valid name" do
    bad_guy = User.new(@attr.merge(:name => ""))
    bad_guy.should_not be_valid
  end

  it "should need a unique name" do
    bad_guy = User.new(@attr.merge(:name => ""))
    bad_guy.should_not be_valid
  end

  it "should need a valid pass" do
    bad_guy = User.new(@attr.merge(:pass => ""))
    bad_guy.should_not be_valid
  end

  it "should need a valid mail" do
    bad_guy = User.new(@attr.merge(:email => ""))
    bad_guy.should_not be_valid
  end

  it "should accept a valid email address" do
    adresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    adresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject an unvalid email address" do
    adresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    adresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject a non-unique email address" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr.merge(:name => "Valid name"))
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject a non-unique name" do
    User.create!(@attr)
    user_with_duplicate_name = User.new(@attr.merge(:email => "valid@email.test"))
    user_with_duplicate_name.should_not be_valid
  end

  it "should reject an unvalid email address (case sensitive)" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr.merge(:name => 'Valid name'))
    user_with_duplicate_email.should_not be_valid
  end
end
