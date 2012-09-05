#!/usr/bin/env ruby

require 'ffi-ncurses'

def save file, buf
  file.write buf
end

def read_init buf
  FFI::NCurses.initscr
  FFI::NCurses.noecho
  FFI::NCurses.raw
  FFI::NCurses.addstr buf
  FFI::NCurses.move 0, 0
end

def move key, buf
  if key == FFI::NCurses::KEY_UP and getcury > 0
    FFI::NCurses.move(getcurx, getcury - 1)
  elsif key == FFI::NCurses::KEY_DOWN and getcury < getmaxy
    FFI::NCurses.move(getcurx, getcury + 1)
  else
    return false
  end
  return true
end

def reading file, buf
  key = FFI::NCurses.getch
  if key == FFI::NCurses::KEY_CTRL_X
    key = FFI::NCurses.getch
    if key == FFI::NCurses::KEY_CTRL_S
      save file, buf
    elsif key == FFI::NCurses::KEY_CTRL_C
      return
    end
  else
    if not move key, buf
      FFI::NCurses.addch key
      buf += FFI::NCurses::keyname key
    end
  end
  reading file, buf
end

if ARGV.count > 0
  file = File.open ARGV[0], "a+"
  buf = file.read
  read_init buf
  reading file, buf
  file.close
  FFI::NCurses.endwin
end
