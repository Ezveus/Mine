#!/usr/bin/env ruby

class Buffer
  def initialize fileLocation, fileName, fileContent, serverSide
    @fileLocation = fileLocation
    @fileName = fileName
    @id = Random.rand.to_i
    @rights = {}
    @serverSide = serverSide
    @workingUsers = []
    @fileContent = fileContent
  end

  def insertText cursor, text
    dataStr = @fileContent[cursor.line]
    s1 = dataStr[0, cursor.column]
    s2 = dataStr[cursor.column, dataStr.size - cursor.column]
    dataStr = s1 + text + s2
    @fileContent[cursor.line] = dataStr.split(/\n/)
    cursor.moveDown(@fileContent[cursor.line].size - 1)
    @fileContent = @fileContent.flatten
    if dataStr.rindex(/\n/)
      lastLineInserted = (text.split(/\n/)).last.size
      cursorColumn = cursor.column
      if cursorColumn < lastLineInserted
        cursor.moveRight(lastLineInserted - cursorColumn)
      elsif cursorColumn > lastLineInserted
        cursor.moveLeft(cursorColumn - lastLineInserted)
      end
    else
      cursor.moveRight(dataStr.size)
    end
    # call the method to update the clients
  end

end
