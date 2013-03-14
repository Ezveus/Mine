# -*- coding: utf-8 -*-
module Mine
  #
  # Class FileInfos :
  # Stores the information of the file
  # for use by the server
  #
  class FileInfos
    attr_reader :path, :user, :group, :userRights
    attr_reader :groupRights, :othersRights, :errors

    class << self
      #
      # Returns an array with all the files
      #
      def getFiles
        files = []
        Modeles::File.all.each do |f|
          files << FileInfos.new(f)
        end
        files
      end
      
      #
      # Returns a FileInfos object
      #
      def selectFile filepath, user, group
        path = "#{user}/#{group}/#{filepath}"
        file = Modeles::File.find_by_path path
        FileInfos.new file if file
      end

      #
      # Add a file in the database and returns the
      # corresponding FileInfos
      #
      def addFile path, username, groupname, rights
        userRights = getUserRights rights
        groupRights = getGroupRights rights
        othersRights = getOthersRights rights
        file = Modeles::File.new(:path => username + '/' +
                                 groupname + '/' +
                                 path,
                                 :userRights => userRights,
                                 :groupRights => groupRights,
                                 :othersRights => othersRights)
        user = Modeles::User.find_by_name username
        return nil if user.nil?
        group = Modeles::Group.find_by_name groupname
        return nil if group.nil?
        file.user = user
        file.group = group
        ret = file.save
        if ret
          FileInfos.new file
        end
      end

      def getUserRights right
        r = right.to_i / 0100 % 010
        if r > 07
          r = 07
        end
        r
      end

      def getGroupRights right
        r = right.to_i / 010 % 010
        if r > 07
          r = 04
        end
        r
      end

      def getOthersRights right
        r = right.to_i % 010
        if r > 07
          r = 04
        end
        r
      end
    end

    def initialize fileInTable
      _, _, path = fileInTable.path.split '/', 3
      @errors = []
      @fileInTable = fileInTable
      @path = path
      @user = @fileInTable.user.name
      @group = @fileInTable.group.name
      @userRights = @fileInTable.userRights
      @groupRights = @fileInTable.groupRights
      @othersRights = @fileInTable.othersRights
    end

    #
    # Stores database error messages in @errors
    #
    def updateErrors
      @errors = []
      @fileInTable.errors.messages.each do |key, value|
        @errors << "#{key} #{value[0]}"
      end
      false
    end

    #
    # Save the file, call updateErrors then returns true
    # or false
    #
    def save
      ret = @fileInTable.save
      updateErrors unless ret
      ret
    end

    def to_s
      "#{@path} [#{@user} #{@group}] <#{rights.to_s 8}>"
    end

    def == a
      @path == a.path and @user == a.user and @group == a.group and @userRights == a.userRights and @groupRights == a.groupRights and @othersRights == a.othersRights
    end

    def != a
        !(self == a)
    end

    def rights
      r = 0 + @userRights * 0100
      r += @groupRights * 010
      r + @othersRights
    end

    def path= path
      @path = path
      @fileInTable.path = @user + '/' + @group + '/' + @path
      save
    end

    def user= user
      unless user.class == Modeles::User
        username = user.to_s
        user = Modeles::User.find_by_name username
        unless user
          @errors << "User #{username} doesn't exists"
          return false
        end
      end
      @fileInTable.user = user
      @fileInTable.path = user.name + '/'
      @fileInTable.path += @group + '/' + @path
      @user = user.name
      @path = @user + '/' + @group + '/' + @path
      save
    end

    def group= group
      unless group.class == Modeles::Group
        groupname = group.to_s
        group = Modeles::Group.find_by_name groupname
        unless group
          @errors << "Group #{group} doesn't exists"
          return false
        end
      end
      @fileInTable.group = group
      @fileInTable.path = @user + '/'
      @fileInTable.path += group.name + '/' + @path
      @group = group.name
      @path = @user + '/' + @group + '/' + @path
      save
    end

    def rights= rights
      rights = rights.to_i
      @fileInTable.userRights = FileInfos.getUserRights rights
      @fileInTable.groupRights = FileInfos.getGroupRights rights
      @fileInTable.othersRights = FileInfos.getOthersRights rights
      @userRights = @fileInTable.userRights
      @groupRights = @fileInTable.groupRights
      @othersRights = @fileInTable.othersRights
      save
    end

    #
    # returns true if a user can execute this file
    #
    def canBeReadBy? user
      unless user.class == Modeles::User
        username = user.to_s
        user = Modeles::User.find_by_name username
        unless user
          @errors << "User #{username} doesn't exists"
          return false
        end
      end
      if user.isAdmin == 1
        return true
      elsif user.name == @user
        if @userRights >= 4
          return true
        else
          return false
        end
      elsif isIncludedIn? user.groups, @group
        if @groupRights >= 4
          return true
        else
          return false
        end
      else
        if @othersRights >= 4
          return true
        else
          return false
        end
      end
    end

    #
    # returns true if a user can write this file
    #
    def canBeWrittenBy? user
      unless user.class == Modeles::User
        username = user.to_s
        user = Modeles::User.find_by_name username
        unless user
          @errors << "User #{username} doesn't exists"
          return false
        end
      end
      if user.isAdmin == 1
        return true
      elsif user.name == @user
        if @userRights == 2 or @userRights >= 6
          return true
        else
          return false
        end
      elsif isIncludedIn? user.groups, @group
        if @groupRights == 2 or @groupRights >= 6
          return true
        else
          return false
        end
      else
        if @othersRights == 2 or @othersRights >= 6
          return true
        else
          return false
        end
      end
    end

    #
    # returns true if a user can execute this file
    #
    def canBeExecutedBy? user
      unless user.class == Modeles::User
        username = user.to_s
        user = Modeles::User.find_by_name username
        unless user
          @errors << "User #{username} doesn't exists"
          return false
        end
      end
      if user.isAdmin == 1
        return true
      elsif user.name == @user
        if @userRights == 1 or @userRights == 5 or @userRights == 7
          return true
        else
          return false
        end
      elsif isIncludedIn? user.groups, @group
        if @groupRights == 1 or @groupRights == 5 or @groupRights == 7
          return true
        else
          return false
        end
      else
        if @othersRights == 1 or @othersRights == 5 or @othersRights == 7
          return true
        else
          return false
        end
      end
    end

    #
    # Delete this file from the database
    #
    def delete
      raise "Not Implemented Function"
    end

    private
    def isIncludedIn? tab, name
      tab.each do |cell|
        return true if cell.name == name
      end
      false
    end
  end
end
