module Mine
  #
  # module GroupTable :
  # This module will handle the interactions with the Groups
  # table
  #
  module GroupTable
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
      def updateErrors group
        @@errors = []
        group.errors.messages.each do |key, value|
          @@errors << "#{key} #{value[0]}"
        end
        false
      end

      #
      # Save the group, call updateErrors then returns true
      # or false
      #
      def saveGroup group
        ret = group.save
        updateErrors group unless ret
        ret
      end

      #
      # Returns an array with all the groupnames
      #
      def getGroupNames
        groups = []
        Modeles::Group.all.each do |g|
          groups << g.name
        end
        groups
      end

      #
      # Returns a GroupInfos object
      #
      def selectGroup groupname
        group = Modeles::Group.find_by_name groupname
        if group
          users = []
          group.users.each do |user|
            users << user.name
          end
          return GroupInfos.new group.name, users # , group.file
        end
        nil
      end

      #
      # Add a group in the database
      #
      def addGroup name
        group = Modeles::Group.new :name => name
        saveGroup group
      end

      #
      # Update the informations of a group
      # Returns true if success
      #
      def modGroup name, field, newval
        group = Modeles::Group.find_by_name name
        return false unless group
        case field
        when :name
          group.name = newval
        when :user
          if newval.class == Array
            newval.each do |v|
              group.users << v
            end
          else
            group.users << newval
          end
        when :file
          if newval.class == Array
            newval.each do |v|
              group.files << v
            end
          else
            group.files << newval
          end
        else
          return false
        end
        ret = group.save
        updateErrors group unless ret
        ret
      end

      #
      # Delete a group in the database
      #
      def delGroup name
        raise "Not Implemented Function"
        # TODO:
      end
    end
  end
end
