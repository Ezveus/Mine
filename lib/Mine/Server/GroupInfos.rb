module Mine
  #
  # Class GroupInfos :
  # Stores the information of the group
  # for use by the server
  #
  class GroupInfos
    attr_accessor :name, :users, :files

    def initialize name, users, files = nil
      @name = name
      @users = users
      @files = files
    end

    def to_s
      "#{@name} #{@users}"        # #{files}
    end
  end
end
