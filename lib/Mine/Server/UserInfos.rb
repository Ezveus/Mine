module Mine
  #
  # Class UserInfos :
  # Stores the information of the user
  # for use by the server
  #
  class UserInfos
    attr_reader :name, :groups, :mail, :website
    attr_reader :isAdmin, :files, :errors

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
      def addUser name, pass, mail, site="", *groupnames
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
        isAdmin = 1 if groupnames.include? "root"
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
      # Returns an array with all UserInfos
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
      @groups = getData(:name, user.groups).sort
      @mail = user.email
      @website = user.website
      @isAdmin = user.isAdmin
      @files = getData(:path, user.files).sort
      @errors = []
    end

    def to_s
      res = "#{@name} #{@groups} #{@files}"
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
      @name == u.name and @groups == u.groups and @mail == u.mail and @website == u.website and @isAdmin == u.isAdmin and @files == u.files
    end

    def != u
      !(self == u)
    end

    def pass= newval
      @userInTable.pass = newval
      save
    end

    def matchPass pass
      @userInTable.pass == pass
    end

    def email= newval
      @email = newval
      @userInTable.email = newval
      save
    end

    def website= newval
      @website = newval
      @userInTable.website = newval
      save
    end

    def isAdmin= newval
      @isAdmin = newval
      @userInTable.isAdmin = newval
      save
    end

    #
    # Delete this user from the database
    #
    def delete
      raise "Not Implemented Function"
    end

    def getData data, objects
      res = []
      objects.each do |object|
        if object.methods.include? data
          res << object.method(data).call
        end
      end
      res
    end
  end
end
