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
  deleteuser = Mine::UserInfos.addUser("Delete", "del",
                                       "del@a.net")
  t.shouldSuccess "addUser Delete del del@a.net", deleteuser
  puts deleteuser.to_s
  du = Mine::UserInfos.selectUser "Delete"
  if t.shouldSuccess "selectUser Delete A", du == deleteuser
    deleteuser.delete
    puts "Delete : #{deleteuser}"
    t.shouldFail("selectUser Delete B",
                 Mine::UserInfos.selectUser("Delete"),
                 "User Delete was deleted")
  end
  groupUser = Mine::UserInfos.addUser("GroupUser", "grp",
                                      "grp@a.net", "www.g.g",
                                      "Plop", "root", "Mine",
                                      "truc")
  t.shouldSuccess "addUser GroupUser grp grp@a.net www.g.g Plop root Mine truc", groupUser
  puts groupUser.to_s
  t.shouldSuccess("groupUser.groups.include? truc",
                  (groupUser.groups.include? "truc"))
  t.shouldFail("groupUser.groups.include? plip",
               (groupUser.groups.include? "plip"),
               "Group wasn't added to GroupUser")
  t.shouldSuccess("groupUser.addGroup plip",
                  (groupUser.addGroup "plip"))
  t.shouldSuccess("groupUser.groups.include? plip",
                  (groupUser.groups.include? "plip"))
  t.shouldSuccess("groupUser.addGroup GroupUser",
                  (groupUser.addGroup "GroupUser"))
  t.shouldFail("groupUser.delGroup GroupUser",
               (groupUser.delGroup "GroupUser"),
               "A user must belongs to his group")
  t.shouldSuccess("groupUser.delGroup plip",
                  (groupUser.delGroup "plip"))
  t.shouldFail("groupUser.delGroup plip",
               (groupUser.delGroup "plip"),
               "GroupUser doesn't belong to plip")
  t.shouldSuccess("groupUser.addFile fileTest truc",
                  (groupUser.addFile "fileTest", "truc"))
  t.shouldSuccess("groupUser.addFile fileTest truc",
                  (groupUser.addFile "fileTest", "truc"))
  t.shouldFail("groupUser.addFile fileTest MegaPlop",
               (groupUser.addFile "fileTest", "MegaPlop"),
               "GroupUser doesn't belong to MegaPlop")
  t.shouldFail("groupUser.delFile fileTest MegaPlop",
               (groupUser.delFile "fileTest", "MegaPlop"),
               "GroupUser doesn't own fileTest in MegaPlop")
  t.shouldSuccess("groupUser.delFile fileTest truc",
                  (groupUser.delFile "fileTest", "truc"))
end

groupTblTest = Proc.new do |t|
  groups = Mine::GroupInfos.getGroups
  if t.shouldSuccess "getGroups", groups != []
    groups.each do |g|
      gr = Mine::GroupInfos.selectGroup g.name
      t.shouldSuccess "selectGroup #{g}", g == gr
      puts g.to_s
    end
  end
  t.shouldSuccess("addGroup Plip",
                  Mine::GroupInfos.addGroup("Plip"))
  t.shouldFail("addGroup Plip",
               Mine::GroupInfos.addGroup("Plip"),
               "Group Plip already exists")
  plip = Mine::GroupInfos.selectGroup "Plip"
  if t.shouldSuccess "selectGroup Plip", plip
    t.shouldSuccess("plip.name = PlopV2",
                    (plip.name = "PlopV2") == plip.name)
  end
  unknown = Mine::GroupInfos.selectGroup "Unknown"
  t.shouldFail("selectGroup Unknown", unknown,
               "Group Unknown doesn't exist")
  deletegroup = Mine::GroupInfos.selectGroup "Delete"
  if t.shouldSuccess "selectGroup Delete A", deletegroup
    puts deletegroup.to_s
    deletegroup.delete
    puts "Delete : #{deletegroup}"
    t.shouldFail("selectGroup Delete B",
                 Mine::GroupInfos.selectGroup("Delete"),
                 "Group Delete was deleted")
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
  deletefile = Mine::FileInfos.addFile("file.rb",
                                       "Kagnus",
                                       "Idea3", 0600)
  t.shouldSuccess "addFile file.rb Kagnus Idea3 0600", deletefile
  puts deletefile.to_s
  du = Mine::FileInfos.selectFile "file.rb", "Kagnus", "Idea3"
  if t.shouldSuccess "selectFile file.rb A", du == deletefile
    deletefile.delete
    puts "Delete : #{deletefile}"
    t.shouldFail("selectFile file.rb B",
                 Mine::FileInfos.selectFile("file.rb", "Kagnus", "Idea3"),
                 "File file.rb was deleted")
  end
end

Mine::Test.new [ "Mine User Table", "Mine Group Table", "Mine Group User Join Table", "Mine File Table" ], [ userTblTest, groupTblTest, group_userTblTest, fileTblTest ]
