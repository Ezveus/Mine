require 'ffi-ncurses'
require 'rbcurse'
require 'logger'
require 'singleton'
load 'MineKey.rb'

module Mine
  ##
  ## This class represent the Mine Window.
  ## It's composed of a rbcurse Window and a rbcurse Form and a Widgets tab.
  ## The rbcurse Form is a container which uses the rbcurse Window to write to.
  ## The Widgets Tab contains rbcurse Widgets created thanks to the widgets tab parameter
  ## at the initilisation of the Mine WIndow.
  ##
  public
  class Window
    include Singleton

    attr_reader :form, :index

    BOLD = Ncurses::A_BOLD

    # This function initilialize the Mine Window the first time.
    # It is composed of Mine Widgets.
    def init(mine_widgets = nil)
      unless @window
        # Init curses.
        VER::start_ncurses
        $log = Logger.new(nil)

        # Init rbcurse Window.
        @window = VER::Window.root_window
        Ncurses.nl

        # Init Form.
        @form = Form.new @window do modified = true end

        return self
      end

      # Init widgets.
      return self unless mine_widgets
      self.widgets = mine_widgets
      @index = 0

      # Refresh.
      @form.handle_key 0
      Ncurses.use_default_colors
      @window.wrefresh

      self
    end

    # This function close the Mine Window.
    def close
      @window.destroy if @window
      VER::stop_ncurses
    end

    # This function read a character.
    def read
      @window.getch
    end

    # This function write a character.
    def write(ch)
      @form.handle_key ch
      @widgets[@index].update_text
    end

    # This function resize a widget.
    def resize(width = max_width, height = max_height)
      @widgets[@index].width = width
      @widgets[@index].height = height
      @widgets[@index].repaint
      self.write Mine::Key.RESIZE
    end

    # This function write the corresponding buffer to the target file.
    def >> (file_name, i = @index)
      if ((File.writable? file_name or not File.exists? file_name) and not
          File.directory? (file = File.new(file_name, 'w')))
        buff = @widgets[i].update_text
        i = 1
        size = buff.length
        buff.each do |line|
          line = line.chop
          line += "\n" unless i == size
          i += 1
          file.write line
        end
      end
      file.close if file
    end

    # This function return the corresponding Mine Widget.
    def [](i)
      @widgets[i]
    end

    # This function update the corresponding Mine Widget.
    def []=(i, widget)
      init_widget
      @widgets[i] = widget
    end

    # This function add a Mine Widget.
    def add_widget(widget)
      init_widget widget
      @widgets << widget
    end

    # This function return a Mine Widget.
    def widgets
      @widgets
    end

    # This function initialise the Mine Widget tab.
    def widgets=(mine_widgets)
      @widgets = []
      mine_widgets.each { |widget| self.add_widget widget }
    end

    # This function return the Mine Window max width
    def max_width
      FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
    end

    # This function return the Mine Window max height
    def max_height
      FFI::NCurses.getmaxy(FFI::NCurses.stdscr)
    end

    private

    # This function initialize a widget and bind
    def init_widget(widget)
      widget.init
      widget.bind if widget.bindings
    end
  end
end
