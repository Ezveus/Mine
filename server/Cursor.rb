#!/usr/bin/env ruby

# 
# Class Cursor :
# Used to manage the cursor of a user on a buffer
# There is a bunch of function to move it on a given file
# 

class Cursor
  attr_reader :line
  attr_reader :column
  attr_reader :owner
  attr_accessor :file

  # 
  # Initializes the cursor assigning to it :
  #  - it's owner
  #  - the file on which the cursor is working
  #  - the line of the file where the cursor is put (0 by default)
  #  - the column number (0)
  # 
  def initialize owner, file, line = 0
    @line = line
    @column = 0
    @owner = owner
    @file = file
  end

  # 
  # Moves the cursor to @line - nbMove.
  # If already on line 0 sets the column to 0.
  # 
  def moveUp nbMove = 1
    (1..nbMove).each do
      if @line > 0
        @line -= 1
      else
        @column = 0
      end
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @column + nbMove.
  # If the cursor is at the end of the line : goes to next line & sets @column to 0.
  # 
  def moveRight nbMove = 1
    (1..nbMove).each do
      if @file[@line].size <= @column
        @line += 1
        @column = 0
      else
        @column += 1
      end
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @line + nbMove.
  # If the cursor is at the end of @file : sets the column to the end of line.
  # 
  def moveDown nbMove = 1
    (1..nbMove).each do
      if @line < @file.length - 1
        @line += 1
      else
        @column = @file[@line].size
      end
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @column - nbMove
  # If the cursor is at beginning of line :
  #  - goes to previous line 
  #  - sets @column to the end of line
  # 
  def moveLeft nbMove = 1
    @column = @file[@line].size if @column > @file[@line].size
    (1..nbMove).each do
      @column = @file[@line].size if @column > @file[@line].size
      if @column > 0
        @column -= 1
      elsif @line > 0
        @line -= 1
        @column = @file[@line].size
      end
    end
    [@line, @column]
  end

  #
  # Moves the cursor to the specified index on the same line
  #
  def moveToColumn index
    if index > @column
      moveRight index - @column
    elsif index < @column
      moveLeft @column - index
    end
  end

  #
  # Moves the cursor to the specified line
  #
  def moveToLine index
    if index > @line
      moveDown index - @line
    elsif index < @line
      moveUp @line - index
    end
  end

  #
  # Moves the cursor to the current line origin
  #
  def moveToOrigin
    @column = 0
    [@line, @column]
  end

  #
  # Moves the cursor to the current line end
  #
  def moveToEnd
    @column = @file[@line].size
    [@line, @column]
  end


  #
  # Check if the cursor is at the end of the current line
  #
  def isAtEOL?
    @column == @file[@line].size
  end

  #
  # Check if the cursor is at the beginning of the current line
  #
  def isAtBOL?
    @column == 0
  end

end
