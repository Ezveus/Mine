#!/usr/bin/env ruby

class Buffer
  attr_reader :fileContent

  def initialize fileLocation, fileName, fileContent, serverSide, eofnewline = true
    @fileLocation = fileLocation
    @fileName = fileName
    @id = Random.rand.to_i
    @rights = {}
    @serverSide = serverSide
    @workingUsers = []
    @fileContent = fileContent
    @eofnewline = eofnewline
  end

  def printFileContent
    puts "file\n#{@fileContent}\n\n"
  end

  def insertText cursor, text
    if @fileContent.size == 1 and @fileContent[0] == ""
      # empty file
      @fileContent[cursor.line] = text.split(/\n/)
      dataStr = text
    else
      # filled file
      cursor.moveLeft
      cursor.moveRight
      dataStr = @fileContent[cursor.line]
      s1 = dataStr[0, cursor.column]
      s2 = dataStr[cursor.column, dataStr.size - cursor.column]
      @fileContent[cursor.line] = (s1 + text + s2).split(/\n/)
    end

    # flatten of the split
    splitSize = @fileContent[cursor.line].size - 1
    @fileContent = @fileContent.flatten
    cursor.file = @fileContent

    # cursor line replacement
    if splitSize > 0
      cursor.moveDown(splitSize)
    end

    # cursor column replacement
    if dataStr.rindex(/\n/)
      lastLineInserted = (text.split(/\n/)).last.size
      cursorColumn = cursor.column
      if cursorColumn < lastLineInserted
        cursor.moveRight(lastLineInserted - cursorColumn)
      elsif cursorColumn > lastLineInserted
        cursor.moveLeft(cursorColumn - lastLineInserted)
      end
    else
      cursor.moveRight(text.size)
    end
    
    # last '\n' handler
    if text.end_with? "\n" and cursor.column == @fileContent[cursor.line].size and cursor.line == @fileContent.rindex(@fileContent.last)
      @fileContent << ""
      @eofnewline = true
      cursor.moveRight
    else
      @eofnewline = false
    end
    # call the method to update the clients
  end
end
