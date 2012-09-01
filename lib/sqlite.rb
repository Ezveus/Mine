require "sqlite3"

class Userdb
  attr_reader :dbpath

  def initialize
    @dbpath = "users.db"
    first_one = File.exist? @dbpath
    @db = SQLite3::Database.new @dbpath

    unless first_one
      rows = @db.execute <<-SQL
        CREATE TABLE users (
        name varchar(42),
        pass varchar(42),
        email varchar(42),
        website varchar(42)
        );
        SQL

      @db.execute "INSERT INTO users (name, pass, email, website) VALUES (\"root\", \"toor\", \"none\", \"none\")"
    end

    puts "TEST ---"
    @db.execute "SELECT * FROM users" do |row| puts row end
    puts "--- TSET"
  end

end

if __FILE__ == $0
  mydb = Userdb.new
end
