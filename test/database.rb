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
  users = Mine::UserInfos.getUsers
  if t.shouldSuccess "getUsers", users != []
    users.each do |u|
      us = Mine::UserInfos.selectUser u.name
      t.shouldSuccess "selectUser #{u}", u == us
      puts u.to_s
    end
    root = Mine::UserInfos.selectUser "root"
    t.shouldFail("root.matchPass plop",
                 (root.matchPass "plop"),
                 "Password isn't right")
    t.shouldSuccess "matchPass toor", (root.matchPass "toor")
  end
  t.shouldSuccess("addUser Plop plop plop@a.net www.plop.org",
                  Mine::UserInfos.addUser("Plop", "plop",
                                          "plop@a.net",
                                          "www.plop.org"))
  t.shouldFail("addUser Plop plop baba@a.net www.plop.org",
               Mine::UserInfos.addUser("Plop", "plop",
                                       "baba@a.net",
                                       "www.plop.org"),
               "User Plop already exists")
  t.shouldFail("addUser Baba plop plop@a.net www.plop.org",
               Mine::UserInfos.addUser("Baba", "plop",
                                       "plop@a.net",
                                       "www.plop.org"),
               "Email plop@a.net already used")
  t.shouldFail("addUser Bobo plop boboa.net www.plop.org",
               Mine::UserInfos.addUser("Bobo", "plop",
                                       "boboa.net",
                                       "www.plop.org"),
               "Email isn't well-formated")
  plop = Mine::UserInfos.selectUser "Plop"
  if t.shouldSuccess "selectUser Plop", plop
    t.shouldSuccess("plop.website = plop.site.net",
                    (plop.website = "plop.site.net") == plop.website)
  end
  unknown = Mine::UserInfos.selectUser "Unknown"
  t.shouldFail("selectUser Unknown", unknown,
               "User Unknown doesn't exist")
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
  ezveus = Mine::UserInfos.addUser("Ezveus",
                                   "suevze",
                                   "ezveus@a.com",
                                   "www.ezveus.com",
                                   "root", "Mine",
                                   "SharpSoul",
                                   "MLP")
  if t.shouldSuccess "addUser Ezveus", ezveus
    ezveus2 = Mine::UserInfos.selectUser "Ezveus"
    t.shouldSuccess "ezveus == ezveus2", ezveus == ezveus2
      puts ezveus.to_s
  end
  users = Mine::UserInfos.addUsers([ "Nain", "nian",
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
                     users != {})
    nain = Mine::UserInfos.selectUser "Nain"
    t.shouldSuccess "selectUser Nain", nain
    puts nain.to_s
    t.shouldSuccess "nain == users[Nain]", nain == users["Nain"]
    [ "Kagnus", "Adaedra" ].each do |username|
      user = Mine::UserInfos.selectUser "#{username}"
      t.shouldSuccess "selectUser #{username}", user
      puts user.to_s
      t.shouldSuccess "#{username} == users[#{username}]", user == users[username]
    end
  end
end

fileTblTest = Proc.new do |t|
  files = Mine::FileInfos.getFiles
  if t.shouldFail("getFiles", files != [],
                  "No files in table")
    t.shouldFail("selectFile fichierBidon",
                 Mine::FileInfos.selectFile("fichierBidon", "Plop", "Plip"),
                 "fichierBidon doesn't exist")
  end
  file = Mine::FileInfos.addFile("FileInfos.rb",
                                 "Ezveus",
                                 "Mine",
                                 0751)
  t.shouldSuccess("addFile FileInfos.rb for Ezveus in Mine",
                  file)
  t.shouldFail("addFile FileInfos.rb for Ezveus in Mine",
               Mine::FileInfos.addFile("FileInfos.rb",
                                       "Ezveus", "Mine",
                                       0751),
               "File FileInfos.rb for Ezveus in Mine " +
               "already exists")
  t.shouldSuccess("addFile FileInfos.rb for Nain in Mine",
                  Mine::FileInfos.addFile("FileInfos.rb",
                                          "Nain", "Mine",
                                          0751))
  t.shouldSuccess("addFile FileInfos.rb for Ezveus in " +
                  "Ezveus",
                  Mine::FileInfos.addFile("FileInfos.rb",
                                          "Ezveus", "Ezveus",
                                          0751))
  files = Mine::FileInfos.getFiles
  if t.shouldSuccess "getFiles", files != []
    files.each do |f|
      fl = Mine::FileInfos.selectFile f.path, f.user, f.group
      t.shouldSuccess "selectFile #{f.path}", f == fl
      puts f.to_s
    end
  end
  
  file = Mine::FileInfos.addFile("file.rb",
                                 "Adaedra", "Idea3", 0751)
  puts "file : #{file}"
  t.shouldSuccess("file.path = lib/Mn/Srv/a.rb",
                  (file.path = "lib/Mn/Srv/a.rb") == file.path)
  # Administrator
  t.shouldSuccess("file.canBeReadBy? Ezveus",
                  (file.canBeReadBy? "Ezveus"))
  # Owner
  t.shouldSuccess("file.canBeReadBy? Adaedra",
                  (file.canBeReadBy? "Adaedra"))
  # Group
  t.shouldSuccess("file.canBeReadBy? Kagnus",
                  (file.canBeReadBy? "Kagnus"))
  # Others
  t.shouldFail("file.canBeReadBy? Plop",
               (file.canBeReadBy? "Plop"),
               "Others can only execute")
  # Administrator
  t.shouldSuccess("file.canBeWrittenBy? Ezveus",
                  (file.canBeWrittenBy? "Ezveus"))
  # Owner
  t.shouldSuccess("file.canBeWrittenBy? Adaedra",
                  (file.canBeWrittenBy? "Adaedra"))
  # Group
  t.shouldFail("file.canBeWrittenBy? Kagnus",
               (file.canBeWrittenBy? "Kagnus"),
               "Group can read and execute")
  # Others
  t.shouldFail("file.canBeWrittenBy? Plop",
               (file.canBeWrittenBy? "Plop"),
               "Others can only execute")
  # Administrator
  t.shouldSuccess("file.canBeExecutedBy? Ezveus",
                  (file.canBeExecutedBy? "Ezveus"))
  # Owner
  t.shouldSuccess("file.canBeExecutedBy? Adaedra",
                  (file.canBeExecutedBy? "Adaedra"))
  # Group
  t.shouldSuccess("file.canBeExecutedBy? Kagnus",
                  (file.canBeExecutedBy? "Kagnus"))
  # Others
  t.shouldSuccess("file.canBeExecutedBy? Plop",
                  (file.canBeExecutedBy? "Plop"))
  t.shouldSuccess("file.rights = 0777",
                  (file.rights = 0777))
  t.shouldSuccess("file.canBeReadBy? Plop",
                  (file.canBeReadBy? "Plop"))
  t.shouldSuccess("file.user = Kagnus",
                  (file.user = "Kagnus") == file.user)
  t.shouldFail("file.user = UnknownUser",
               (file.user = "UnknownUser") == file.user,
               "UnknownUser doesn't exist")
  puts "file : #{file}"
  t.shouldSuccess("file.group = Mine",
                  (file.group = "Mine") == file.group)
  t.shouldFail("file.group = UnknownGroup",
               (file.group = "UnknownGroup") == file.group,
               "UnknownGroup doesn't exist")
  puts "file : #{file}"
end

Mine::Test.new [ "Mine User Table", "Mine Group Table", "Mine Group User Join Table", "Mine File Table" ], [ userTblTest, groupTblTest, group_userTblTest, fileTblTest ]
