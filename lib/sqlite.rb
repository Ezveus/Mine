#!/usr/bin/env ruby
require "sqlite3"

#
# Class Userdb :
# User database containing the list of the users and associated
# informations : password hash, email, website
#

class Userdb
  attr_reader :dbpath

  #
  # Initializes the database "users.db"
  # Creates the file and fill it with the root user
  # if it does not exists
  #
  def initialize
    @dbpath = "users.db"
    first_one = File.exist? @dbpath
    @db = SQLite3::Database.new @dbpath

    unless first_one
      rows = @db.execute <<-SQL
        CREATE TABLE users (
        name varchar(42),
        pass varchar(42),
        email varchar(42),
        website varchar(42)
        );
        SQL

      @db.execute "INSERT INTO users (name, pass, email, website) VALUES (\"root\", \"toor\", \"none\", \"none\")"
    end
  end

  #
  # Returns an array with all the usernames
  #
  def selectUsers
    stmt = @db.prepare "SELECT name FROM users"
    stmt.execute!.flatten
  end

  #
  # Returns an array with all informations about a user
  #
  def selectUser username
    stmt = @db.prepare "SELECT * FROM users WHERE name IS \"#{username}\""
    stmt.execute!.flatten
  end

  #
  # Matches a user pass with the stored hash
  #
  def cmpPass username, pass
    stmt = @db.prepare "SELECT pass FROM users WHERE name IS \"#{username}\""
    pass == stmt.execute!.flatten[0]
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
  usersInfo = mydb.selectUser "root"
  puts "=> selectUser root : #{usersInfo}"
  cmp_pass = mydb.cmpPass "root", "plop"
  puts "=> cmpPass root plop : #{cmp_pass}"
  cmp_pass = mydb.cmpPass "root", "toor"
  puts "=> cmpPass root toor : #{cmp_pass}"
end
