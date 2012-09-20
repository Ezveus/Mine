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
  # Class User :
  # Inherits from ActiveRecord::Base
  # Represents a user
  #
  class User < ActiveRecord::Base
    attr_accessible :name, :pass, :email, :website
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
      rootUser = User.create :id => 0, :name => "root", :pass => "toor", :email => "none", :website => "none"
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
    [user.name, user.email, user.website]
  end

  #
  # Matches a user pass with the stored hash
  #
  def matchPass username, pass
    user = User.find_by_name username
    user.pass == pass
  end

  #
  # Add a user in the database
  # Returns true if success
  #
  def addUser username, pass, mail="none", site="none"
    user = User.new :name => username, :pass => pass, :email => mail, :website => site
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
  add_user = mydb.addUser "plop", "polp", "plop@a.net", "www.plop.org"
  puts "=> addUser plop polp plop@a.net www.plop.org : #{add_user}"
end
