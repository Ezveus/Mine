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
      #      self.widgets = widgets
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
    def resize(width = max_x, height = max_y)
      @rbc_widgets[@index].width = width
      @widgets[@index].width = width
      @rbc_widgets[@index].height = height
      @widgets[@index].height = height
      @rbc_widget[@index].print_borders
      @rbc_widget[@index].set_modified
      @rbc_widget[@index].repaint
      self.write Mine::Key.RESIZE
    end

    # This function refresh bindings of all widgets.
    def rebind_all
      @widgets.each_index { |i| rebind i }
    end

    # This function refresh bindings of the target widget.
    def rebind(i)
      @widgets[i].bindings.each do |b|
        @rbc_widgets[i].bind_key(b.key, &method(b.call))
      end
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

    def max_x
      FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
    end

    def max_y
      FFI::NCurses.getmaxy(FFI::NCurses.stdscr)
    end

    private

    def init_widget(widget)
      widget.repaint
      widget.bind if widget.bindings
    end

    def refresh
      @widgets.each { |widget| widget.refresh @form if TAB.index(widget.class.name) }
    end

    # This function return the name of the Widget independently of its Module.
    def widget_name(widget)
      widget.class.name.partition("::").at(-1)
    end

    # This function convert a Mine Widget to a rbcurse Widget
    # and return the rbcurse Widget.
    def rbcurse_widget(widget)
      eval("RubyCurses::" + widget_name(widget)).new @form, &widget.proc
    end
  end
end
