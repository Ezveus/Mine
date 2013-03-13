module Mine
  #
  # Module Modeles :
  # It contains all the modeles used by ActiveRecord and
  # the associated exceptions
  #
  module Modeles
    #
    # Class DbError :
    # Inherits from Exception
    #
    class DbError < Exception
      def initialize errors
        @errors = errors
      end

      def to_s
        "DbError : #{@errors}"
      end
    end

    #
    # Class User :
    # Inherits from ActiveRecord::Base
    # Represents a user in the database
    #
    class User < ActiveRecord::Base
      has_and_belongs_to_many :groups
      has_many :files

      attr_accessible :name, :pass, :email, :website, :isAdmin

      email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      
      validates :name, :presence => true, :uniqueness => true
      validates :pass, :presence => true
      validates(:email,
                :presence => true,
                :format => { :with => email_regex },
                :uniqueness => { :case_sensitive => false })
    end

    #
    # Class DbErrorUser :
    # Inherits from DbError
    #
    class DbErrorUser < DbError
      def to_s
        "User : #{@errors}"
      end
    end

    #
    # Class Group :
    # Inherits from ActiveRecord::Base
    # Represent a group in the database
    #
    class Group < ActiveRecord::Base
      has_and_belongs_to_many :users
      has_many :files

      attr_accessible :name
      validates :name, :presence => true, :uniqueness => true
    end

    #
    # Class DbErrorGroup :
    # Inherits from DbError
    #
    class DbErrorGroup < DbError
      def to_s
        "Group : #{@errors}"
      end
    end
    
    #
    # Class Files :
    # Inherits from ActiveRecord::Base
    # Represent a file in the database
    #
    class File < ActiveRecord::Base
      belongs_to :user
      belongs_to :group

      attr_accessible :path, :user_id, :group_id
      attr_accessible :userRights, :groupRights, :othersRights
      validates :path, :presence => true, :uniqueness => true
      validates :userRights, :presence => true
      validates :groupRights, :presence => true
      validates :othersRights, :presence => true
    end

    #
    # Class DbErrorFile :
    # Inherits from DbError
    #
    class DbErrorFile < DbError
      def to_s
        "File : #{@errors}"
      end
    end
  end
end
