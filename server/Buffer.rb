#!/usr/bin/env ruby

class Buffer
  attr_reader :fileContent

  def initialize fileLocation, fileName, fileContent, serverSide
    @fileLocation = fileLocation
    @fileName = fileName
    @id = Random.rand.to_i
    @rights = {}
    @serverSide = serverSide
    @workingUsers = []
    @fileContent = fileContent
    @eofnewline = false
    if @fileContent.last.rindex(/\n/)
      @eofnewline = true
    end
  end

  def printFileContent
    puts "file\n#{@fileContent}\n\n"
  end

  def insertText cursor, text
    if @fileContent.size == 1 and @fileContent[0] == ""
      @fileContent[cursor.line] = text.split(/\n/)
      printFileContent
      puts "#{cursor.line}, #{cursor.column}"
      dataStr = text
    else
      cursor.moveLeft
      cursor.moveRight
      dataStr = @fileContent[cursor.line]
      s1 = dataStr[0, cursor.column]
      s2 = dataStr[cursor.column, dataStr.size - cursor.column]
      @fileContent[cursor.line] = (s1 + text + s2).split(/\n/)
    end
    if @fileContent[cursor.line].size - 1 > 0
      cursor.moveDown(@fileContent[cursor.line].size - 1)
    end
    @fileContent = @fileContent.flatten
    cursor.file = @fileContent
    printFileContent
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
    # call the method to update the clients
  end
end
