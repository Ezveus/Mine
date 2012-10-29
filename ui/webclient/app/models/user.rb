class User < ActiveRecord::Base
  attr_accessible :email, :name

  validates(:name,
            :presence => true,
            :length => { :maximum => 50 })
  validates :email, :presence => true
end
