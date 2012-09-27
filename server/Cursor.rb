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

  # 
  # Initializes the cursor assigning to it :
  #  - it's owner
  #  - the file on which the cursor is working
  #  - the line of the file where the cursor is put (0 by default)
  #  - the column number (0)
  #  - the offset value depending on the line number
  # 
  def initialize owner, file, line = 0
    @line = line
    @column = 0
    @owner = owner
    @file = file
    @offset = 0
    i = 0
    while i < @line && @file[@offset] != '\0'
      @offset += 1
      if @file[@offset] == '\n'
        i += 1
      end
    end
    @offset += 1 unless @offset == 0
  end

  # 
  # Moves the cursor to @line - 1.
  # If already on line 0 sets the column to 0.
  # 
  def moveUp
    if @line > 0
      @offset -= 2
      @offset -= 1 until @file[@offset] == '\n' || @offset == 0
      @offset += 1
      @line -= 1
    else
      @column = 0
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @column + 1.
  # If the cursor is at the end of the line : goes to next line & sets @column to 0.
  # 
  def moveRight
    print @file[@offset + @column]
    if @file[@offset + @column] == "\n"
      @offset += @column + 1
      @line += 1
      @column = 0
    else
      @column += 1 if @offset + @column < @file.size
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @line + 1.
  # If the cursor is at the end of @file : sets the column to the end of line.
  # 
  def moveDown
    last_line = @file[@offset, @file.size - @offset]
    if nb = (last_line =~ /\n/)
      @line += 1
      @offset += nb + 1
    else
      @column = last_line.size - 1
    end
    [@line, @column]
  end

  # 
  # Moves the cursor to @column - 1
  # If the cursor is at beginning of line :
  #  - goes to previous line 
  #  - sets @column to the end of line
  # 
  def moveLeft
    if @line > 0
      if @column > 0
        @column -= 1
      else
        @line -= 1
        @offset -= 2
        columns = @offset
        @offset -= 1 while @file[@offset] != "\n" && @offset != 0
        @offset += 1
        @column = columns - @offset + 1
      end
    end
    [@line, @column]
  end

end
