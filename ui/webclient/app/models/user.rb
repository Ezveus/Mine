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

class User < ActiveRecord::Base
  attr_accessible :name, :pass, :email, :website, :isAdmin

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:name,
            :presence => true,
            :uniqueness => true
            )
  validates(:pass,
            :presence => true)
  validates(:email,
            :presence => true,
            :uniqueness => { :case_sensitive => false },
            :format   => { :with => email_regex })
end
