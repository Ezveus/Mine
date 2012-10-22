#!/usr/bin/env ruby

#
# Class Buffer
# Used to manage every action on a buffer
# 

class Buffer

  #
  # Initializes the buffer assigning to it
  #  - the file's location
  #  - the file's name
  #  - the File's content
  #  - if the file is hosted by the server or the client
  #  - if the file is terminated by a new line
  #
  def initialize fileLocation, fileName, fileContent, serverSide, eofnewline = true
    @fileLocation = fileLocation
    @fileName = fileName
    @id = Random.rand.to_i
    @rights = {}
    @serverSide = serverSide
    @workingUsers = []
    @fileContent = fileContent
    @eofNewLine = eofnewline
  end

  #
  # Debuging function
  #
  def printFileContent
    puts "file\n#{@fileContent}\n\n"
  end

  public
  #
  # Insert text in the buffer according to the position of cursor
  # Moves the cursor in consequence
  #
  def insertText cursor, text
    if @fileContent.size == 1 and @fileContent[0] == ""
      dataStr = insertTextEmptyFile cursor, text
    else
      dataStr = insertTextFilledFile cursor, text
    end
    splitSize = insertTextSplitFlatten cursor
    insertTextCursorReplacement text, cursor, splitSize, dataStr
    insertTextNewLineHandler text, cursor

    # call the method to update the clients and make a diff
  end

  #
  # Here is a bunch of functionto insert what we awant were we want
  #
  private
  def insertTextEmptyFile cursor, text
    @fileContent[cursor.line] = text.split(/\n/)
    text
  end

  def insertTextFilledFile cursor, text
    if cursor.column > @fileContent[cursor.line].size
      cursor.moveToColumnIndex @fileContent[cursor.line].size
    end
    dataStr = @fileContent[cursor.line]
    s1 = dataStr[0, cursor.column]
    s2 = dataStr[cursor.column, dataStr.size - cursor.column]
    @fileContent[cursor.line] = (s1 + text + s2).split(/\n/)
    return s1 + text + s2
  end

  def insertTextSplitFlatten cursor
    splitSize = @fileContent[cursor.line].size - 1
    @fileContent = @fileContent.flatten
    cursor.file = @fileContent
    return splitSize
  end

  def insertTextCursorReplacement text, cursor, splitSize, dataStr
    if splitSize > 0
      cursor.moveDown(splitSize)
    end
    if dataStr.rindex(/\n/)
      lastLineInserted = (text.split(/\n/)).last.size
      cursor.moveToColumnIndex lastLineInserted
    else
      cursor.moveRight text.size
    end
  end

  def insertTextNewLineHandler text, cursor
    if text.end_with? "\n" and cursor.column == @fileContent[cursor.line].size and
        cursor.line == @fileContent.rindex(@fileContent.last)
      @fileContent << ""
      @eofNewLine = true
      cursor.moveRight
    else
      @eofNewLine = false
    end
  end

  public
  def eofNewLine?
    if @fileContent.last == "" and @fileContent.size > 1
      @eofNewLine = true
    else
      @eofNewLine = false
    end
  end

  #
  # Delete some characters at the position given by the cursor
  # Moves the cursor in consequence
  #
  def deleteTextBackspace cursor, nbToDelete = 1
    nbToDelete = deleteTextBackspaceTooBig cursor, nbToDelete
    while cursor.column < nbToDelete
      nbToDelete = deleteTextBackspaceConcatLine cursor, nbToDelete
    end
    deleteTextBackspaceSameLine cursor, nbToDelete
    eofNewLine?
    cursor.file = @fileContent
  end
  
  private
  #
  # Here is a bunch of function to delete some text
  #
  def deleteTextBackspaceTooBig cursor, nbToDelete
    nb = nbToDelete - cursor.column
    line = cursor.line - 1
    while nb > 0 && line >= 0
      nb -= @fileContent[line].size + 1
      line -= 1
    end
    if nb <= 0
      return nbToDelete
    else 
      return nbToDelete - nb
    end
  end

  def deleteTextBackspaceSameLine cursor, nbToDelete
    if nbToDelete > 0
      @fileContent[cursor.line] =
        @fileContent[cursor.line][0, cursor.column - nbToDelete] +
        @fileContent[cursor.line][cursor.column, @fileContent[cursor.line].size]
      cursor.moveToColumnIndex cursor.column - nbToDelete
    end
  end

  def deleteTextBackspaceConcatLine cursor, nbToDelete
    column = @fileContent [cursor.line - 1].size
    @fileContent[cursor.line - 1] =
      @fileContent[cursor.line - 1] <<
      @fileContent[cursor.line][cursor.column, @fileContent[cursor.line].size]
    nbToDelete -= cursor.column + 1
    @fileContent.delete_at cursor.line
    cursor.moveUp
    cursor.moveToColumnIndex column
    return nbToDelete
  end

  public
  #
  # Delete characters after the cursor
  #
  def deleteTextDelete cursor, nbToDelete = 1
    nbToDelete = deleteTextDeleteTooBig cursor, nbToDelete
    puts "#{nbToDelete}"
    while cursor.column < nbToDelete
      nbToDelete = deleteTextDeleteConcatLine cursor, nbToDelete
    end
    deleteTextDeleteSameLine cursor, nbToDelete
    eofNewLine?
    cursor.file = @fileContent
  end

  private
  def deleteTextDeleteTooBig cursor, nbToDelete
    line = cursor.line + 1
    nb = nbToDelete - @fileContent[line - 1].size - cursor.column
    while nb > 0 and line < @fileContent.size
      nb -= @fileContent[line].size + 1
      line += 1
    end
    if nb <= 0
      return nbToDelete
    else
      return nbToDelete - nb
    end
  end

  def deleteTextDeleteConcatLine cursor, nbToDelete
    column = @fileContent[cursor.line][cursor.column,
                                       @fileContent[cursor.line].size].size + 1
    @fileContent[cursor.line] = 
      @fileContent[cursor.line][0, cursor.column] +
      @fileContent[cursor.line + 1]
    @fileContent.delete_at cursor.line + 1
    nbToDelete - column
  end

  def deleteTextDeleteSameLine cursor, nbToDelete
    if nbToDelete > 0
      @fileContent[cursor.line] =
        @fileContent[cursor.line][0, cursor.column] +
        @fileContent[cursor.line][cursor.column + nbToDelete,
                                  @fileContent[cursor.line].size]
    end
  end

end
