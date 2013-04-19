module Mine
  #
  # Class UserInfos :
  # Stores the information of the user
  # for use by the server
  #
  class UserInfos
    extend Forwardable

    attr_reader :name, :groups, :mail, :website
    attr_reader :isAdmin, :files, :errors

    def_delegators :@userInTable, :id

    class << self
      #
      # Returns an array with all the users
      #
      def getUsers
        users = []
        Modeles::User.all.each do |u|
          users << UserInfos.new(u)
        end
        users
      end

      #
      # Returns a UserInfos object
      #
      def selectUser username
        user = Modeles::User.find_by_name username
        return UserInfos.new user if user
      end

      #
      # Add a user in the database and
      # create groups if necessary
      # Returns the corresponding UserInfos
      #
      def addUser name, pass, mail, site = "", *groupnames
        groupnames = groupnames.flatten
        userGroup = Modeles::Group.find_by_name name
        if userGroup.nil?
          userGroup = Modeles::Group.new :name => name
        else
          return nil
        end
        groups = [ userGroup ]
        groupnames.flatten.each do |groupname|
          group = Modeles::Group.find_by_name groupname
          if group.nil?
            group = Modeles::Group.new :name => groupname
          end
          groups << group
        end
        isAdmin = 0
        isAdmin = 1 if groupnames.include? "root" or name == "root"
        user = Modeles::User.new(:name => name, :pass => pass,
                                 :email => mail,
                                 :website => site,
                                 :isAdmin => isAdmin)
        user.groups = groups
        ret = user.save
        if ret
          UserInfos.new user
        end
      end

      #
      # Add users in the database and
      # creates groups if necessary
      # Returns a hash with all UserInfos where keys are
      # usernames
      #
      def addUsers *users
        usersInfos = {}
        users.each do |u|
          userInfo = if u[3].class == String && u[4]
                       addUser u[0], u[1], u[2], u[3], u[4]
                     elsif u[3].class == Array
                       addUser u[0], u[1], u[2], "", u[3]
                     else
                       addUser u[0], u[1], u[2], u[3]
                     end
          usersInfos[userInfo.name] = userInfo
        end
        usersInfos
      end
    end

    def initialize user
      @userInTable = user
      @name = user.name
      @groups = {}
      user.groups.each do |group|
        @groups[group.name] = GroupInfos.new group
      end
      @mail = user.email
      @website = user.website
      @isAdmin = user.isAdmin
      @files = {}
      user.files.each do |file|
        @files[files.path] = FileInfos.new file
      end
      @errors = []
    end

    def to_s
      return "" if @name.nil?
      res = "#{@name} #{@groups.keys.sort} #{@files.keys.sort}"
      if @isAdmin == 1
        res += " # "
      else
        res += " $ "
      end
      res += "<"
      res += "@ : #{@mail}"
      res += ", web : #{@website}" if @website and @website != ""
      res + ">"
    end

    #
    # Stores database error messages in @@errors
    #
    def updateErrors
      @errors = []
      @userInTable.errors.messages.each do |key, value|
        @errors << "#{key} #{value[0]}"
      end
      false
    end

    #
    # Save the user, call updateErrors then returns true
    # or false
    #
    def save
      ret = @userInTable.save
      updateErrors unless ret
      ret
    end

    def == u
      @name == u.name and @groups.keys.sort == u.groups.keys.sort and @mail == u.mail and @website == u.website and @isAdmin == u.isAdmin and @files.keys.sort == u.files.keys.sort
    end

    def != u
      !(self == u)
    end

    #
    # save the new value of the pass in the database
    #
    def pass= newval
      @userInTable.pass = newval
      save
    end

    def matchPass pass
      @userInTable.pass == pass
    end

    #
    # Save the new value of the email in the database
    #
    def email= newval
      @email = newval
      @userInTable.email = newval
      save
    end

    #
    # Save the new value of the website in the database
    #
    def website= newval
      @website = newval
      @userInTable.website = newval
      save
    end

    #
    # set if th euser is an admin of the server and save it in the database
    #
    def isAdmin= newval
      @isAdmin = newval
      @userInTable.isAdmin = newval
      save
    end

    #
    # add a group, create the directories, and save the rights in the database
    #
    def addGroup groupname
      return true if @groups.include? groupname
      group = getModele(Modeles::Group, "name", groupname,
                        {
                          :name => groupname
                        })
      @userInTable.groups << group
      ret = @userInTable.save
      if ret
        @groups[groupname] = GroupInfos.new group
        true
      else
        false
      end
    end

    #
    # delete a group, delete the directories, and delete it from the database
    #
    def delGroup groupname
      return false if groupname == @name
      return false unless @groups.include? groupname
      group = getModele Modeles::Group, "name", groupname
      @userInTable.groups.delete group
      ret = @userInTable.save
      if ret
        @groups.delete groupname
        Modeles::Group.delete group.id
        true
      else
        false
      end
    end

    #
    # add a file in the database and save it
    #
    def addFile filepath, groupname
      path = "#{@name}/#{groupname}/#{filepath}"
      return true if @files.include? path
      return false unless @groups.include? groupname
      file = getModele(Modeles::File, "path", path,
                       {
                         :path => path,
                         :user_id => @userInTable.id,
                         :group_id => @groups[groupname].id,
                         :userRights => 6,
                         :groupRights => 4,
                         :othersRights => 0
                       })
      @userInTable.files << file
      ret = @userInTable.save
      if ret
        @files[path] = FileInfos.new file
        true
      else
        false
      end
    end

    #
    # delete a file and delete it from the database
    #
    def delFile filepath, group
      path = "#{@name}/#{group}/#{filepath}"
      return false unless @files.include? path
      file = getModele Modeles::File, "path", path
      @userInTable.files.delete file
      ret = @userInTable.save
      if ret
        @files.delete path
        Modeles::File.delete file.id
        true
      else
        false
      end
    end

    #
    # Delete this user from the database
    #
    def delete
      Modeles::User.delete @userInTable.id
      @userInTable = nil
      @name = nil
      @groups = nil
      @mail = nil
      @website = nil
      @isAdmin = nil
      @files = nil
      @errors = nil
    end

    private
    def getData data, objects
      res = []
      objects.each do |object|
        if object.methods.include? data
          res << object.method(data).call
        end
      end
      res
    end

    def getModele acmodele, prop, value, hash = nil
      m = acmodele.where("#{prop} = ?", value).first
      if m.nil?
        return nil if hash.nil?
        m = acmodele.new hash
        m.save
      end
      m
    end
  end
end
