module Mine

  # This function init fbuffers.
  def init_fbuffers
    files_name = []
    buffers = []
    @files = ARGV
    exit unless @files
    @fbuffers = []
    @files.each do |file_name|
      buffer = ''
      if File.exist? file_name
        err_directory if File.directory?(file = File.new(file_name, 'r'))
        buffer = file.read
        file.close
      end
      @fbuffers << buffer
    end
    @fbuffers
  end

  def run
    begin
      catch :close do
        loop { window.write(window.read) }
      end
    rescue => ex
    ensure
      window.close if window
    end
  end

  def window(widgets = nil)
    win = Window.instance
    win.init(widgets)
  end

  def files
    @files
  end

  def files= names
    @files = names
  end

  def file (i = window.index)
    @files[i]
  end

  def file= (name, i = window.index)
    @files[i] = name
  end

  def fbuffers
    @fbuffers
  end

  def widgets
    @widgets
  end

  module_function :init_fbuffers, :run, :window, :widgets
  module_function :files= , :files, :file= , :file, :fbuffers
end
