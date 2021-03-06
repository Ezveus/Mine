module MineClient

  # This function inits fbuffers.
  def init_fbuffers
    # here should be MineBuffer
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

  # This function is the Mine Client's main loop.
  def run
    # here should the connection be established
    connection = Connection.instance
    connection.config
    connection.connect
    connection.authenticate
    begin
      catch :close do
        loop do
          # here a little magic should be done
          window.write window.read
        end
      end
    rescue => ex
      $stderr.puts "#{ex}"
    ensure
      window.close if window
    end
  end

  # This function returns the Mine Window's instance.
  def window widgets = nil
    win = Window.instance
    win.init widgets
  end

  def files
    @files
  end

  def files= names
    @files = names
  end

  def file i = window.index
    @files[i]
  end

  def file= name, i = window.index
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
