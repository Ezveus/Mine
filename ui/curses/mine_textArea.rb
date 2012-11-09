#!/usr/bin/env ruby

require 'ffi-ncurses'
require 'logger'
require 'rbcurse'
require 'rbcurse/core/widgets/rwidget'
require 'rbcurse/core/widgets/rtextarea'

begin
  VER::start_ncurses
  $log = Logger.new "view.log"
  $log.level = Logger::DEBUG

  @window = VER::Window.root_window
  Ncurses.nl

  @form = Form.new @window do
    modified = true
  end

  catch(:close) do
    texta = TextArea.new @form do
      name  "mytext"
      row  0
      col  0
      width FFI::NCurses.getmaxx FFI::NCurses.stdscr
      height FFI::NCurses.getmaxy FFI::NCurses.stdscr
      title "Editable box"
      title_attrib Ncurses::A_BOLD
    end

    Ncurses.use_default_colors
    @window.wrefresh

    #    $key_map = :emacs
    # load file [ test ]
    #    file = File.open "./test.rb", "r+"
    #    texta << file.read
    loop do
      ch = @window.getch
      break if (ch == FFI::NCurses::KEY_CTRL_X and @window.getch == FFI::NCurses::KEY_CTRL_C)
      @form.handle_key ch
      # catch sigchwin and use :
      # texta.width = FFI::NCurses.getmaxx(FFI::NCurses.stdscr)
      # texta.height = FFI::NCurses.getmaxy(FFI::NCurses.stdscr)
    end
  end
rescue => ex
ensure
  @window.destroy if !@window.nil?
  VER::stop_ncurses
end
