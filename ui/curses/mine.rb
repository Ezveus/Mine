#!/usr/bin/env ruby

require 'ffi-ncurses'
require 'logger'
require 'rbcurse'
require 'rbcurse/core/widgets/rwidget'

# move the cursor ... twice otherwise it doesn't work
def curs_move x, y
  @window.wmove x, y
  @window.wmove @window.x, @window.y
end

# Move the cursor
def curs_moveLeft
  unless (@window.x == 0 and @window.y == 0)
    if @window.x > 0
      curs_move @window.x - 1, @window.y
      return 0
    else
      curs_move @line_sizes[@line - 1], @window.y - 1
      return 1
    end
  end
  return -1
end


# Delete one character. To delete a character, we need to move the cursor on it
# and then to delete it.
# Do not forget to decrement the line index or the line_size counter.
def curs_delch
  mv = curs_moveLeft
  if mv == 0
    @window.delch
    @line_sizes[@line] -= 1
  elsif mv == 1
    @line -= 1
  end
end

# Add one character and increment the line_size counter
def curs_addch ch
#  @window.mvcur @window.y, @window.x, @window.y + 1, @window.x + 1
  @window.addch ch
  @line_sizes[@line] += 1
end

# Add a new line and increment the line index
def curs_nl
  @window.addch 10
  @line += 1
  if @line_sizes.size > @line
    @line_sizes.insert(@line + 1, 0)
  else
    @line_sizes << 0
  end
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
  @line = 0
  @line_sizes = [0]
  Ncurses.nl
  Ncurses.use_default_colors
  @window.refresh
  catch(:close) do
    loop do
      ch = @window.getch()
      next if ch == -1
      break if (ch == FFI::NCurses::KEY_CTRL_X and @window.getch() == FFI::NCurses::KEY_CTRL_C)
      if (ch == Ncurses::KEY_BSPACE)
        curs_delch
      elsif (ch == 10) # FFI::NCurses::KEY_ENTER do not return 10 ('\n') even if we expect it ...
        curs_nl
      elsif (ch == FFI::NCurses::KEY_LEFT)
        curs_moveLeft
      else
        curs_addch ch
      end
    end
  end
rescue => ex
ensure
  #  @window.destroy if !@window.nill?
  VER::stop_ncurses
end
