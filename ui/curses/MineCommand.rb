module Mine
  module Command
    def save
      Mine.window >> Mine.file
    end
    def resize
      return
      Mine.window.resize
    end
    def exit
      throw :close
    end

    module_function :save, :resize, :exit
  end
end

