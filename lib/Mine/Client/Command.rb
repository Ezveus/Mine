module MineClient
  module Command
    def save
      MineClient.window >> MineClient.file
    end
    def resize
      return
      MineClient.window.resize
    end
    def exit
      throw :close
    end

    module_function :save, :resize, :exit
  end
end
