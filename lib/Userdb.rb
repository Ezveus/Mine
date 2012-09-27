#!/usr/bin/env ruby
require 'active_record'
require 'logger'

#
# Class Userdb :
# User database containing the list of the users and associated
# informations : password hash, email, website
#
class Userdb
  attr_reader :dbpath

  #
  # class CreateUsers :
  # Inherits ActiveRecord::Migration
  # Manage creation and destruction of the table
  #
  class CreateUsers < ActiveRecord::Migration

    #
    # Creates the table
    #
    def self.up
      create_table :users do |t|
        t.string :name
        t.string :pass
        t.string :email
        t.string :website
        t.timestamps
      end
    end

    #
    # Destroys the table
    #
    def self.down
      drop_table :users
    end
  end

  #
  # Class AddUniquenessIndex
  # Inherits ActiveRecord::Migration
  # Creates indexes on users=>email and users=>name
  #
  class AddUniquenessIndex < ActiveRecord::Migration
    def self.up
      add_index :users, :email, :unique => true
      add_index :users, :name, :unique => true
    end

    def self.down
      remove_index :users, :name
      remove_index :users, :email
    end
  end

  #
  # Class User :
  # Inherits from ActiveRecord::Base
  # Represents a user
  #
  class User < ActiveRecord::Base
    attr_accessible :name, :pass, :email, :website
    validates :name, :presence => true, :uniqueness => true
    validates :pass, :presence => true
    validates :email, :uniqueness => { :case_sensitive => false }

    before_save :encrypt_password

    private
    def encrypt_password
      self.encrypted_password = encrypt(pass)
    end

    def encrypt str
      str
    end
  end

  #
  # Initializes the database "users.db"
  # Creates the file and fill it with the root user
  # if it does not exists
  #
  def initialize
    @dbpath = "users.db"
    first_one = File.exist? @dbpath
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
    ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => @dbpath

    unless first_one
      CreateUsers.up
      AddUniquenessIndex.up
      rootUser = User.create :id => 0, :name => "root", :pass => "toor"
    end
  end

  #
  # Returns an array with all the usernames
  #
  def selectUsers
    users = []
    User.all.each do |u|
      users << u.name
    end
    users
  end

  #
  # Returns an array with all informations about a user
  #
  def selectUser username
    user = User.find_by_name username
    [user.name, user.email, user.website] if user
  end

  #
  # Matches a user pass with the stored hash
  #
  def matchPass username, pass
    user = User.find_by_name username
    user.pass == pass if user
  end

  #
  # Add a user in the database
  # Returns true if success
  #
  def addUser username, pass, mail="none", site="none"
    user = User.new :name => username, :pass => pass, :email => mail, :website => site
    user.save
  end

  #
  # Update the informations of a user
  # Returns true if success
  #
  def modUser username, field, newval
    user = User.find_by_name username
    return false unless user
    if field == :pass
      user.pass = newval
    elsif field == :email
      user.email = newval
    elsif field == :website
      user.website = newval
    else
      return false
    end
    user.save
  end
end

#
# Tests all the functions
#
if __FILE__ == $0
  puts "Testing SQLite Class"
  mydb = Userdb.new
  users = mydb.selectUsers
  puts "=> selectUsers : #{users}"
  users.each do |u|
    usersInfo = mydb.selectUser u
    puts "=> selectUser #{u} : #{usersInfo}"
  end
  cmp_pass = mydb.matchPass "root", "plop"
  puts "=> matchPass root plop : #{cmp_pass}"
  cmp_pass = mydb.matchPass "root", "toor"
  puts "=> matchPass root toor : #{cmp_pass}"
  add_user = mydb.addUser "Plop", "plop", "plop@a.net", "www.plop.org"
  puts "=> addUser Plop plop plop@a.net www.plop.org : #{add_user}"
  add_user = mydb.addUser "Plop", "plop", "baba@a.net", "www.plop.org"
  puts "=> addUser Plop plop baba@a.net www.plop.org : #{add_user}"
  add_user = mydb.addUser "Baba", "plop", "plop@a.net", "www.plop.org"
  puts "=> addUser Baba plop plop@a.net www.plop.org : #{add_user}"
  add_user = mydb.addUser "Bobo", "plop", "boboa.net", "www.plop.org"
  puts "=> addUser Bobo plop boboa.net www.plop.org : #{add_user}"
  mod_user = mydb.modUser "Plop", :website, "plop.site.net"
  puts "=> modUser Plop :website plop.site.net : #{mod_user}"
  usersInfo = mydb.selectUser "Plop"
  puts "=> selectUser Plop : #{usersInfo}"
  mod_user = mydb.modUser "root", :something, "plop.site.net"
  puts "=> modUser root :something plop.site.net : #{mod_user}"
  usersInfo = mydb.selectUser "root"
  puts "=> selectUser root : #{usersInfo}"
  mod_user = mydb.modUser "Unknown", :website, "plop.site.net"
  puts "=> modUser Unknown :website plop.site.net : #{mod_user}"
  usersInfo = mydb.selectUser "Unknown"
  puts "=> selectUser Unknown : #{usersInfo}"
end
