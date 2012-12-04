#!/usr/bin/env ruby

require 'ffi-ncurses'
require 'rbcurse'
require 'logger'
require 'rbcurse/core/widgets/rwidget'
require 'rbcurse/core/widgets/rtextarea'
load    "MTextArea.rb"


## exit if there is no param
exit if ARGV.size == 0
FILE_NAME = ARGV[0]

## error if open file is a directory
def err_directory
  puts FILE_NAME + " is an existing directory."
  file.close
  exit
end

## init curses
def init_curses
  VER::start_ncurses
  $log = Logger.new nil # "log"
  # $log.level = Logger::DEBUG
end

## init the window, a form and the textArea
def init_MineWin
  @window = VER::Window.root_window
  Ncurses.nl

  @form = Form.new @window do
    modified = true
  end

  @textArea = TextArea.new @form do
    name FILE_NAME
    row  0
    col  0
    width FFI::NCurses.getmaxx FFI::NCurses.stdscr
    height FFI::NCurses.getmaxy FFI::NCurses.stdscr
    title FILE_NAME
    title_attrib Ncurses::A_BOLD
  end
  @textArea << @buf

  Ncurses.use_default_colors
  @window.wrefresh
end

## binding
def init_binding
  $key_map = :emacs
  @textArea.bind_key [?\C-x, ?\C-c] do
    exit
  end
  @textArea.bind_key [?\C-x, ?\C-s] do
    @file.write @textArea.get_text
  end
end

## open a file and save contents in buf
@buf = ""
if File.exist? FILE_NAME
  err_directory(file) if File.directory?(file = File.new(FILE_NAME, "r"))
  @buf = file.read
  file.close
end
@file = File.new FILE_NAME, "w"

## Mine
begin
  init_curses
  catch(:close) do
    init_MineWin
    init_binding

    loop do
      ch = @window.getch
      if ch == FFI::NCurses::KEY_RESIZE
        @textArea.resize
      else
        @form.handle_key ch
      end
    end
  end
rescue => ex
ensure
  @file.close
  @window.destroy if !@window.nil?
  VER::stop_ncurses
end
