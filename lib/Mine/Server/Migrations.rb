module Mine
  #
  # Module Migrations :
  # It contains all the migrations applied to the database
  #
  module Migrations
    #
    # class CreateUsers :
    # Inherits ActiveRecord::Migration
    # Manage creation and destruction of the table
    #
    class CreateUsers < ActiveRecord::Migration

      #
      # Creates the table
      #
      def self.up
        create_table :users do |t|
          t.string :name
          t.string :pass
          t.string :email
          t.string :website
          t.integer :isAdmin
          t.timestamps
        end
      end

      #
      # Destroys the table
      #
      def self.down
        drop_table :users
      end
    end

    #
    # class CreateGroups :
    # Inherits ActiveRecord::Migration
    # Manage creation and destruction of the table
    #
    class CreateGroups < ActiveRecord::Migration

      #
      # Creates the table
      #
      def self.up
        create_table :groups do |t|
          t.string :name
          t.timestamps
        end
      end

      #
      # Destroys the table
      #
      def self.down
        drop_table :groups
      end
    end

    #
    # CreateFiles :
    # Inherits ActiveRecord::Migration
    # Manage creation and destruction of the table
    #
    class CreateFiles < ActiveRecord::Migration

      #
      # Creates the table
      #
      def self.up
        create_table :files do |t|
          t.string :path
          t.integer :userRights
          t.integer :groupRights
          t.integer :othersRights
          t.integer :user_id
          t.integer :group_id
          t.timestamps
        end
      end

      #
      # Destroys the table
      #
      def self.down
        drop_table :files
      end
    end

    #
    # CreateGroupsUsersJoinTable :
    # Inherits ActiveRecord::Migration
    # Manage creation and destruction of the join table
    # between Groups and Users
    # 
    class CreateGroupsUsersJoinTable < ActiveRecord::Migration
      def self.up
        create_table :groups_users, :id => false do |t|
          t.integer :group_id
          t.integer :user_id
        end
      end

      def self.down
        drop_table :groups_users
      end
    end

    #
    # Class AddUniquenessIndex
    # Inherits ActiveRecord::Migration
    # Creates indexes on :
    # users=>email,
    # users=>name,
    # groups=>name,
    # files=>path
    #
    class AddUniquenessIndex < ActiveRecord::Migration
      def self.up
        add_index :users, :email, :unique => true
        add_index :users, :name, :unique => true
        add_index :groups, :name, :unique => true
        add_index :files, :path, :unique => true
        add_index :groups_users, [:group_id, :user_id], :unique => true
      end

      def self.down
        remove_index :users, :name
        remove_index :users, :email
        remove_index :groups, :name
        remove_index :files, :path
      end
    end

    #
    # Applies all migrations
    #
    def self.up
      CreateUsers.up
      CreateGroups.up
      CreateFiles.up
      CreateGroupsUsersJoinTable.up
      AddUniquenessIndex.up
    end
  end
end
