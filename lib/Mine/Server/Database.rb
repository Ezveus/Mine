module Mine
  #
  # Class Database :
  # It will be called at launch to initialize the database
  # and its tables
  #
  class Database
    @@instance = nil
    attr_reader :dbpath, :errors

    #
    # Initializes the database "mine.db"
    # by applying all migrations
    #
    def self.instance dbpath = "mine.db"
      unless @@instance
        @@instance = Database.new dbpath
        private_class_method :new
      end
      @@instance
    end

    def initialize dbpath = "mine.db"
      @dbpath = dbpath
      @errors = []
      fileExist = ::File.exist? @dbpath
      ActiveRecord::Base.logger = Logger.new ::File.open('database.log', 'w')
      ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => @dbpath

      unless fileExist
        Migrations.up
        UserInfos.addUser "root", "toor", "root@localhost.localdomain"
      end
    end
  end
end
