require 'ffi-ncurses'
require 'rbcurse'
require 'logger'
require 'singleton'
load 'MineForm.rb'
load 'MineKey.rb'

module Mine
  ##
  ## This class represents the Mine Window.
  ## It's composed of a rbcurse Window and a Mine Form which is composed of
  ## Mine Widgets and a rbcurse Form.
  ## The rbcurse Form is a container which uses the rbcurse Window to write to.
  ## The Widgets Tab contains rbcurse Widgets created thanks to the widgets tab parameter
  ## at the initilisation of the Mine Window.
  ##
  public
  class Window
    include Singleton

    BOLD = Ncurses::A_BOLD

    # This function initilializes the Mine Window the first time.
    # It is composed of Mine Widgets.
    def init(mine_widgets = nil)
      unless @window
        # First call
        # Init curses.
        VER::start_ncurses
        $log = Logger.new(nil)

        # Init rbcurse Window.
        @window = VER::Window.root_window
        Ncurses.nl
      else
        # Init Form and Widgets
        return self unless mine_widgets
        @form = Mine::Form.new @window
        @form.init_widgets mine_widgets

        # Refresh.
        @form.write 0
        Ncurses.use_default_colors
        @window.wrefresh
      end
      self
    end

    # This function returns the Mine Window max width
    def max_width
      FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
    end

    # This function returns the Mine Window max height
    def max_height
      FFI::NCurses.getmaxy(FFI::NCurses.stdscr)
    end

    # This function closes the Mine Window.
    def close
      @window.destroy if @window
      VER::stop_ncurses
    end

    # This function resizes a widget.
    def resize(width = max_width, height = max_height)
      @form.resize(width, height)
      self.write Mine::Key.RESIZE
    end

    # This function reads a character.
    def read
      @window.getch
    end

    # This function writes a character.
    def write(ch)
      @form.write ch
    end

    # This function writes the corresponding buffer to the target file.
    def >> (file_name, i = index)
      if ((File.writable? file_name or not File.exists? file_name) and not
          File.directory? (file = File.new(file_name, 'w')))
        buff = @form[i].update_text
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

    # This function returns the rbcurse Form.
    def form
      @form.rbc_form
    end

    # This function returns the corresponding Mine Widget.
    def [](i)
      @form[i]
    end

    # This function updates the corresponding Mine Widget.
    def []=(i, widget)
      @form[i] = widget
    end

    # This function adds a Mine Widget.
    def add_widget(widget)
      @form.add_widget
    end

    # This function adds a Mine Widget at the index i.
    # If the index is greater than the Widget tab size,
    # it adds it at the end.
    def add_widget_at(widget, i)
      @form.add_widget_at widget, i
    end

    # This function deletes a Mine Widget.
    def delete_widget(widget)
      @widgets.delete widget
    end

    # This function deletes the Mine Widget at the corresponding index.
    def delete_widget_at(i)
      @widgets.delete_at i
    end

    # This function returns the Mine Widget which corresponds to the given hash.
    # Returns nil if fails.
    def find_widget(widget_description)
      @form.find_widget(widget_description)
    end

    # This function returns an Array of the Mine Widgets
    # which correspond to the given hash.
    # Returns nil if fails.
    def find_widgets(widgets_description)
      @form.find_widgets(widgets_description)
    end

    # This function returns the index of the Mine Widget
    # which corresponds to the given hash.
    # Returns nil if fails.
    def find_widget_index(widget_description)
      @form.find_widget_index(widget_description)
    end

    # This function returns an Array of the index of the Mine Widgets
    # which correspond to the given hash.
    # Returns nil if fails.
    def find_widgets_index(widgets_description)
      @form.find_widgets_index(widgets_description)
    end

    # This function returns a Mine Widget.
    def widgets
      @form.widgets
    end

    # This function initialises the Mine Widget tab.
    def widgets=(mine_widgets)
      @form.wigets = mine_widgets
    end

    # This function returns the index of the current Widget.
    def index
      @form.index
    end
  end
end
