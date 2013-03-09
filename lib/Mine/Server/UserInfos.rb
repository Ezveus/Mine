module Mine
  #
  # Class UserInfos :
  # Stores the information of the user
  # for use by the server
  #
  class UserInfos
    attr_accessor :name, :mail, :website, :isAdmin

    def initialize name, mail, website, isAdmin, groups = nil
      @name = name
      @groups = groups || name
      @mail = mail
      @website = website
      @isAdmin = isAdmin
    end

    def to_s
      res = "#{@name} #{@groups}"
      res += " # " if @isAdmin == 1
      res += " $ " unless @isAdmin == 1
      res += "<"
      res += "@ : #{@mail}"
      res += ", web : #{@website}" if @website and @website != ""
      res += ">"
    end
  end
end
