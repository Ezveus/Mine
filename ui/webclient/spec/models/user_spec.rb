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
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance with valids attributes" do
    User.create!(@attr)
  end

  describe "Name Tests" do
    it "should need a name" do
      bad_guy = User.new(@attr.merge(:name => ""))
      bad_guy.should_not be_valid
    end

    it "should reject too long names" do
      long_name = "a" * 51
      long_name_user = User.new(@attr.merge(:name => long_name))
      long_name_user.should_not be_valid
    end

    it "should reject a non-unique name" do
      User.create!(@attr)
      user_with_duplicate_name = User.new(@attr.merge(:email => "another@valid.email"))
      user_with_duplicate_name.should_not be_valid
    end
  end

  describe "Email Tests" do
    it "should need a mail" do
      bad_guy = User.new(@attr.merge(:email => ""))
      bad_guy.should_not be_valid
    end

    it "should reject unvalid email" do
      adresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      adresses.each do |adress|
        invalid_email_user = User.new(@attr.merge(:email => adress))
        invalid_email_user.should_not be_valid
      end
    end

    it "should reject a non-unique email (checking case)" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email,
                               :name => "User 1"))
      user_with_duplicate_email = User.new(@attr.merge(:name => "User 2"))
      user_with_duplicate_email.should_not be_valid
    end
  end

  describe "Passwords Tests" do
    it "should have a password" do
      u = User.new(@attr.merge(:password => "",
                               :password_confirmation => ""))
      u.should_not be_valid
    end

    it "should need a password confirmation identical to the password" do
      u = User.new(@attr.merge(:password_confirmation => "invalid"))
      u.should_not be_valid
    end

    it "should reject too short passwords" do
      short = "a" * 5
      u = User.new(@attr.merge(:password => short,
                               :password_confirmation => short))
      u.should_not be_valid
    end

    it "should reject too long passwords" do
      long = "a" * 41
      u = User.new(@attr.merge(:password => long,
                               :password_confirmation => long))
      u.should_not be_valid
    end

    describe "Encryption tests" do
      before :each do
        @user = User.create! @attr
      end

      it "should exist an encrypted_password attribute" do
        @user.should respond_to(:encrypted_password)
      end

      it "should define the encrypted password" do
        @user.encrypted_password.should_not be_blank
      end

      describe "has_password?" do
        it "should return true if submitted password is the one" do
          @user.has_password?(@attr[:password]).should be_true
        end

        it "should return false if submitted password isn't the one" do
          @user.has_password?("invalide").should be_false
        end
      end

      describe "Authenticate Method" do
        it "should return nil in case of inadequation between email/name and password" do
          wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
          wrong_password_user.should be_nil
        end

        it "should return nil when an email has no associated user" do
          nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
          nonexistent_user.should be_nil
        end

        it "should return nil when a name has no associated user" do
          nonexistent_user = User.authenticate("plop", @attr[:password])
          nonexistent_user.should be_nil
        end

        it "should return the user if email and password match" do
          matching_user = User.authenticate(@attr[:email], @attr[:password])
          matching_user.should == @user
        end

        it "should return the user if name and password match" do
          matching_user = User.authenticate(@attr[:name], @attr[:password])
          matching_user.should == @user
        end
      end
    end
  end
end
