#!/usr/bin/env ruby

require 'ffi-ncurses'
require 'logger'
require 'rbcurse'
require 'rbcurse/core/widgets/rwidget'

begin
  VER::start_ncurses
  @window = VER::Window.root_window
  Ncurses.nl
  catch(:close) do
    while ((ch = @window.getch()) != 27)
      next if ch == -1
      @window.addch ch
    end
  end
rescue => ex
ensure
  #  @window.destroy if !@window.nill?
  VER::stop_ncurses
end
