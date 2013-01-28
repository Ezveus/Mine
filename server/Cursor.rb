#!/usr/bin/env ruby

# 
# Class Cursor :
# Used to manage the cursor of a user on a buffer
# There is a bunch of function to move it on a given file
# 
module Mine
  class Cursor
    attr_reader :line, :column, :owner, :file

    # 
    # Initializes the cursor assigning to it :
    #  - it's owner
    #  - the file on which the cursor is working
    #  - the line of the file where the cursor is put (0 by default)
    #  - the column number (0)
    # 
    def initialize owner, file, line = 0
      @column = 0
      @owner = owner
      @file = file
      if line < file.size
        @line = line
      else
        @line = file.size - 1
      end
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
      @column = index
      [@line, @column]
    end

    #
    # Moves the cursor to the specified line
    #
    def moveToLine index
      @line = index
      [@line, @column]
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

    #
    # Check if the cursor is at the end of file
    #
    def isAtEOF?
      @line == @file.size - 1 and isAtEOL?
    end

    #
    # Check if the cursor is at the beginning of file
    #
    def isAtBOF?
      @line == 0 and isAtBOL?
    end
  end
end
