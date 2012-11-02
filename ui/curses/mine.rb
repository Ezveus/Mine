#!/usr/bin/env ruby

require 'ffi-ncurses'
require 'logger'
require 'rbcurse'
require 'rbcurse/core/widgets/rwidget'

# We'll send a request to the server for curs_move and curs_delch
# to get the new position.
# ------------------------

# move the cursor
def curs_move x, y
  @window.wmove x, y
  @window.wmove @window.x, @window.y
end

# delete one character. To delete a character, we need to move the cursor on it
# and then to delete it.
def curs_delch
  curs_move @window.x - 1, @window.y
  @window.delch
end

## ---------------------
## Mine client
## - Curses and window initialisation
## - event loop to get characters (C-x C-c to quit)
## - print characters or delete it
## TODO-001 : print only printables characters
begin
  VER::start_ncurses
  @window = VER::Window.root_window
  Ncurses.nl
  catch(:close) do
    loop do
      ch = @window.getch()
      next if ch == -1
      break if (ch == FFI::NCurses::KEY_CTRL_X and @window.getch() == FFI::NCurses::KEY_CTRL_C)
      if (ch == 127)
        curs_delch
      elsif (ch == FFI::NCurses::KEY_ENTER)
        curs_move 0, @window.y + 1
      else
        @window.addch ch
      end
    end
  end
rescue => ex
ensure
  #  @window.destroy if !@window.nill?
  VER::stop_ncurses
end
