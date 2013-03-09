#!/usr/bin/env ruby
## database.rb for project Mine Database Tests
## 
## Made by Matthieu Ciappara
## Mail : <ciappam@gmail.com>
## 
## Started by Matthieu Ciappara on Sat Mar  2 18:52:34 2013
##

$:.unshift '../lib' unless $:.index '../lib'
$:.unshift '../lib/Mine' unless $:.index '../lib/Mine'
load "test.rb"

require 'Mine'
require 'Mine/Server'

dbpath = "test.db"
begin
  File.delete dbpath
rescue Errno::ENOENT
end
mydb = Mine::Database.instance dbpath

userTblTest = Proc.new do |t|
  t.shouldSuccess "Mine::Database.instance", Mine::Database.instance == mydb
  users = Mine::UserTable.getUserNames
  if t.shouldSuccess "getUserNames", users != []
    users.each do |u|
      t.shouldSuccess("selectUser #{u}",
                      (us = Mine::UserTable.selectUser(u)))
      puts "#{us}"
    end
    t.shouldFail("matchPass root plop",
                 Mine::UserTable.matchPass("root", "plop"),
                 "Password isn't right")
    t.shouldSuccess("matchPass root toor",
                    Mine::UserTable.matchPass("root", "toor"))
  end
  t.shouldSuccess("addUser Plop plop plop@a.net www.plop.org",
                  Mine::UserTable.addUser("Plop", "plop",
                                          "plop@a.net",
                                          "www.plop.org"))
  t.shouldFail("addUser Plop plop baba@a.net www.plop.org",
               Mine::UserTable.addUser("Plop", "plop",
                                       "baba@a.net",
                                       "www.plop.org"),
               "User Plop already exists")
  t.shouldFail("addUser Baba plop plop@a.net www.plop.org",
               Mine::UserTable.addUser("Baba", "plop",
                                       "plop@a.net",
                                       "www.plop.org"),
               "Email plop@a.net already used")
  t.shouldFail("addUser Bobo plop boboa.net www.plop.org",
               Mine::UserTable.addUser("Bobo", "plop",
                                       "boboa.net",
                                       "www.plop.org"),
               "Email isn't well-formated")
  if t.shouldSuccess("modUser Plop :website plop.site.net",
                     Mine::UserTable.modUser("Plop", :website,
                                             "plop.site.net"))
    t.shouldSuccess("selectUser Plop website = plop.site.net",
                    (Mine::UserTable.selectUser("Plop").website ==
                     "plop.site.net"))
  end
  if t.shouldFail("modUser root :something plop.site.net",
                  Mine::UserTable.modUser("root", :something,
                                          "plop.site.net"),
                  ":something isn't a User field")
    t.shouldSuccess("selectUser root website unchanged",
                    (Mine::UserTable.selectUser("root").website ==
                     "" ||
                     Mine::UserTable.selectUser("root").website.nil?))
  end
  if t.shouldFail("modUser Unknown :website plop.site.net",
                  Mine::UserTable.modUser("Unknown", :website,
                                          "plop.site.net"),
                  "User Unknown doesn't exist")
    t.shouldFail("selectUser Unknown",
                 Mine::UserTable.selectUser("Unknown"),
                 "User Unknown doesn't exist")
  end
  if t.shouldSuccess("addUser Test plop test@a.net",
                     Mine::UserTable.addUser("Test", "plop",
                                             "test@a.net"))
    t.shouldSuccess("selectUser Test",
                    Mine::UserTable.selectUser("Test"))
  end
end

groupTblTest = Proc.new do |t|
  groups = Mine::GroupTable.getGroupNames
  if t.shouldSuccess "getGroupNames", groups != []
    groups.each do |g|
      t.shouldSuccess("selectGroup #{g}",
                      (gr = Mine::GroupTable.selectGroup(g)))
      puts "#{gr}"
    end
  end
  t.shouldSuccess("addGroup Plip",
                  Mine::GroupTable.addGroup("Plip"))
  t.shouldFail("addGroup Plip",
               Mine::GroupTable.addGroup("Plip"),
               "Group Plip already exists")
  if t.shouldSuccess("modGroup Plip :name PlopV2",
                     Mine::GroupTable.modGroup("Plip", :name,
                                               "PlopV2"))
    t.shouldSuccess("selectGroup PlopV2",
                    (Mine::GroupTable.selectGroup("PlopV2").name == "PlopV2"))
  end
  if t.shouldFail("modGroup root :something plop.site.net",
                  Mine::GroupTable.modGroup("root", :something,
                                            "plop.site.net"),
                  ":something isn't a Group field")
    t.shouldSuccess("selectGroup root name unchanged",
                    (Mine::GroupTable.selectGroup("root").name == "root" ||
                     Mine::GroupTable.selectGroup("root").name.nil?))
  end
  if t.shouldFail("modGroup Unknown :name plip",
                  Mine::GroupTable.modGroup("Unknown", :name,
                                            "plip"),
                  "Group Unknown doesn't exist")
    t.shouldFail("selectGroup Unknown",
                 Mine::GroupTable.selectGroup("Unknown"),
                 "Group Unknown doesn't exist")
  end
end

group_userTblTest = Proc.new do |t|
  if t.shouldSuccess("addUser Ezveus",
                     Mine::UserTable.addUser("Ezveus",
                                             "suevze",
                                             "ezveus@a.com",
                                             "www.ezveus.com",
                                             "root", "Mine",
                                             "SharpSoul",
                                             "MLP"))
    ezveus = Mine::UserTable.selectUser "Ezveus"
    t.shouldSuccess "selectUser Ezveus", ezveus
    puts "#{ezveus}"
  else
    puts "#{Mine::UserTable.errors}"
  end
  res = Mine::UserTable.addUsers([ "Nain", "nian",
                                   "nain@a.com",
                                   "www.nain.com",
                                   [ "root", "Mine",
                                     "MyWMP" ] ],
                                 [ "Kagnus", "sungak",
                                   "kagnus@a.com",
                                   "www.kagnus.com",
                                   [ "Idea3", "MyWMP" ] ],
                                 [ "Adaedra", "ardeada",
                                   "adaedra@a.com",
                                   "www.adaeadra.com",
                                   [ "Idea3",
                                     "MLP" ] ])
  if t.shouldSuccess("addUsers Nain, Kagnus and Adaedra",
                     res)
    nain = Mine::UserTable.selectUser "Nain"
    t.shouldSuccess "selectUser Nain", nain
    puts "#{nain}"
    [ "Kagnus", "Adaedra" ].each do |user|
      user = Mine::UserTable.selectUser "#{user}"
      t.shouldSuccess "selectUser #{user}", user
      puts "#{user}"
    end
  end
end

Mine::Test.new [ "Mine User Table", "Mine Group Table", "Mine Group User Join Table" ], [ userTblTest, groupTblTest, group_userTblTest ]
