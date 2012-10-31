require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :website
  attr_accessible :isAdmin, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:name,
            :presence => true,
            :length => { :maximum => 50 },
            :uniqueness => true)
  validates(:email,
            :presence => true,
            :format => { :with => email_regex },
            :uniqueness => { :case_sensitive => false })
  validates(:password,
            :presence => true,
            :confirmation => true,
            :length => { :within => 6..40 })

  before_save :encrypt_password

  def has_password? password
    self.encrypted_password == encrypt(password)
  end

  def self.authenticate userid, password
    user = self.find_by_name userid
    user = self.find_by_email userid unless user
    return nil unless user
    return user if user.has_password? password
    nil
  end

  private
  def encrypt_password
    self.encrypted_password = encrypt(password)
  end

  def encrypt s
    s
  end
end
