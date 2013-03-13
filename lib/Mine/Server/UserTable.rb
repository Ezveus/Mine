module Mine
  #
  # module UserTable :
  # This module will handle the interactions with the Users
  # table
  #
  module UserTable
    @@errors = []

    class << self
      #
      # Returns @@errors
      #
      def errors
        @@errors
      end

      #
      # Stores database error messages in @@errors
      #
      def updateErrors user
        @@errors = []
        user.errors.messages.each do |key, value|
          @@errors << "#{key} #{value[0]}"
        end
        false
      end

      #
      # Save the user, call updateErrors then returns true
      # or false
      #
      def saveUser user
        ret = user.save
        updateErrors user unless ret
        ret
      end

      #
      # Returns an array with all the usernames
      #
      def getUserNames
        users = []
        Modeles::User.all.each do |u|
          users << u.name
        end
        users
      end

      #
      # Returns a UserInfos object
      #
      def selectUser username
        user = Modeles::User.find_by_name username
        if user
          groups = []
          user.groups.each do |group|
            groups << group.name
          end
          return UserInfos.new(user.name, user.email,
                               user.website, user.isAdmin,
                               groups)
        end
        nil
      end

      #
      # Matches a user pass with the stored hash
      #
      def matchPass username, pass
        user = Modeles::User.find_by_name username
        user.pass == pass if user
      end

      #
      # Add a user in the database and
      # create groups if necessary
      # Returns true if success
      #
      def addUser name, pass, mail, site="", *groupnames
        groupnames = groupnames.flatten
        userGroup = Modeles::Group.find_by_name name
        if userGroup.nil?
          userGroup = Modeles::Group.new :name => name
        else
          @@errors << "Group #{name} already exists"
          return false
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
        saveUser user
      end

      #
      # Add users in the database and
      # creates groups if necessary
      # Returns true if success
      #
      def addUsers *users
        users.each do |u|
          if u[3].class == String && u[4]
            addUser u[0], u[1], u[2], u[3], u[4]
          elsif u[3].class == Array
            addUser u[0], u[1], u[2], "", u[3]
          else
            addUser u[0], u[1], u[2], u[3]
          end
        end
      end

      #
      # Update the informations of a user
      # Returns true if success
      #
      def modUser username, field, newval
        user = Modeles::User.find_by_name username
        return false unless user
        case field
        when :pass
          user.pass = newval
        when :email
          user.email = newval
        when :website
          user.website = newval
        when :isAdmin
          user.isAdmin = newval
        else
          return false
        end
        saveUser user
      end

      #
      # Delete a user in the database
      # Returns true if success
      #
      def delUser username
        raise "Not Implemented Function"
        updateErrors user unless ret
        ret
      end
    end
  end
end
