module Mine
  #
  # Class GroupInfos :
  # Stores the information of the group
  # for use by the server
  #
  class GroupInfos
    attr_reader :name, :users, :files, :errors

    class << self
      #
      # Returns an array with all the groups
      #
      def getGroups
        groups = []
        Modeles::Group.all.each do |g|
          groups << GroupInfos.new(g)
        end
        groups
      end

      #
      # Returns a GroupInfos object
      #
      def selectGroup groupname
        group = Modeles::Group.find_by_name groupname
        return GroupInfos.new group if group
      end

      #
      # Add a group in the database and returns the
      # corresponding GroupInfo
      #
      def addGroup name
        group = Modeles::Group.new :name => name
        ret = group.save
        if ret
          GroupInfos.new group
        end
      end

      #
      # Add Groups in the database and returns an array
      # containing the GroupInfos where keys are groupnames
      #
      def addGroups *groups
        groupsInfos = {}
        groups.each do |g|
          groupInfo = addGroup g
          groupsInfos[groupInfo.name] = groupInfo
        end
        groupsInfos
      end
    end

    def initialize group
      @groupInTable = group
      @name = group.name
      @users = getData(:name, group.users).sort
      @files = getData(:path, group.files).sort
      @errors = []
    end

    #
    # Stores database error messages in @errors
    #
    def updateErrors
      @errors = []
      @groupInTable.errors.messages.each do |key, value|
        @errors << "#{key} #{value[0]}"
      end
      false
    end

    #
    # Save the group, call updateErrors then returns true
    # or false
    #
    def save
      ret = @groupInTable.save
      updateErrors unless ret
      ret
    end

    def to_s
      "#{@name} #{@users} #{files}"
    end

    def == g
      @name == g.name and @users == g.users and @files == g.files
    end

    def != g
      !(self == g)
    end

    def name= newval
      @name = newval
      @groupInTable.name = newval
      save
    end

    #
    # Delete this group from the database
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
