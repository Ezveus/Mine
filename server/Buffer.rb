#!/usr/bin/env ruby

#
# Class Buffer
# Used to manage every action on a buffer
# Also managing the diffHistory
# 

require 'diff/lcs'
load 'server/Change.rb'

class Buffer

  attr_reader :fileContent

  #
  # Initializes the buffer assigning to it
  #  - the file's location
  #  - the file's name
  #  - the File's content
  #  - if the file is hosted by the server or the client
  #  - if the file is terminated by a new line
  #  - the diffHistory of the buffer (common to each user on buffer)
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
    @diffHistory = []
    @diffHistoryPosition = 0
  end

  public
  #
  # Method to add a user to the list of the working users
  #
  def addWorkingUser user
    @workingUsers << user
  end

  public
  #
  # Method to remove a user from the list of the working users
  #
  def removeWorkingUser user
    @workingUsers.delete user
  end

  public
  #
  # Test if the Buffer is terminated by a new line or not
  #
  def eofNewLine?
    if @fileContent.last == "" and @fileContent.size > 1
      @eofNewLine = true
    else
      @eofNewLine = false
    end
  end

  # public
  # #
  # #
  # #
  # def overwriteText cursor, text
  #   if cursor.isAtEOL? or cursor.isAtEOF?
  #     insertText cursor, text
  #   else

  #   end
  # end 

  # private
  # #
  # #
  # #
  # def overwrite c, text
  #   pos = text =~ /\n/
  #   unless pos
  #     @fileContent[c.line].replace (@fileContent[c.line][0, c.column]
  #                                   << text
  #                                   << @fileContent[c.line][c.column + text.size,
  #                                                           @fileContent[c.line].size])
  #     c.moveToColumn c.column + text.size
  #   else
  #     if @fileContent[c.line][c.column, @fileContent[c.line].size].size > pos
  #       # we are fucked
  #     else
  #       @fileContent[c.line].replace (@fileContent[c.line][0, c.column]
  #                                     << text[0, pos])
  #       c.moveToColumn c.column + pos
  #       insertText cursor, text[pos, text.size]
  #     end
  #   end
  # end

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
  end

  private
  #
  # Here is a bunch of function to insert what we want where we want
  #
  def insertTextEmptyFile cursor, text
    @fileContent[cursor.line].replace splitText text
    text
  end

  def insertTextFilledFile cursor, text
    if cursor.column > @fileContent[cursor.line].size
      cursor.moveToColumn @fileContent[cursor.line].size
    end
    dataStr = @fileContent[cursor.line]
    s1 = dataStr[0, cursor.column]
    s2 = dataStr[cursor.column, dataStr.size - cursor.column]
    @fileContent[cursor.line] = splitText(s1 + text + s2)
    return s1 + text + s2
  end

  def insertTextSplitFlatten cursor
    splitSize = @fileContent[cursor.line].size - 1
    @fileContent.replace @fileContent.flatten
    return splitSize
  end

  def insertTextCursorReplacement text, cursor, splitSize, dataStr
    if splitSize > 0
      cursor.moveDown(splitSize)
    end
    if dataStr.rindex(/\n/)
      lastLineInserted = (splitText text).last.size
      cursor.moveToColumn lastLineInserted
    else
      cursor.moveRight text.size
    end
  end

  def insertTextNewLineHandler text, cursor
    if text.end_with? "\n" and cursor.column == @fileContent[cursor.line].size and
        cursor.line == @fileContent.rindex(@fileContent.last)
      @eofNewLine = true
      cursor.moveRight
    else
      @eofNewLine = false
    end
  end

  public
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

  def deleteTextBackspaceSameLine c, nbToDelete
    if nbToDelete > 0
      if c.isAtEOL?
        eol = true
      else
        eol = false
      end
      @fileContent[c.line] = @fileContent[c.line][0, c.column - nbToDelete] +
        @fileContent[c.line][c.column, @fileContent[c.line].size]
      if eol
        c.moveToEnd
      else
        c.moveToColumn c.column - nbToDelete
      end
    end
  end

  def deleteTextBackspaceConcatLine c, nbToDelete
    column = @fileContent [c.line - 1].size
    @fileContent[c.line - 1] = @fileContent[c.line - 1] <<
      @fileContent[c.line][c.column, @fileContent[c.line].size]
    nbToDelete -= c.column + 1
    @fileContent.delete_at c.line
    c.moveUp
    c.moveToColumn column
    return nbToDelete
  end

  public
  #
  # Delete characters after the cursor
  #
  def deleteTextDelete c, nbToDelete = 1
    nbToDelete = deleteTextDeleteTooBig c, nbToDelete
    while @fileContent[c.line].size - c.column < nbToDelete
      nbToDelete = deleteTextDeleteConcatLine c, nbToDelete
    end
    deleteTextDeleteSameLine c, nbToDelete
    eofNewLine?
  end

  private
  #
  # Here is a bunch of function to delete text
  #
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

  def deleteTextDeleteConcatLine c, nbToDelete
    column = @fileContent[c.line][c.column, @fileContent[c.line].size].size + 1
    @fileContent[c.line] = @fileContent[c.line][0, c.column] +
      @fileContent[c.line + 1]
    @fileContent.delete_at c.line + 1
    nbToDelete - column
  end

  def deleteTextDeleteSameLine c, nbToDelete
    if nbToDelete > 0
      @fileContent[c.line] = @fileContent[c.line][0, c.column] +
        @fileContent[c.line][c.column + nbToDelete, @fileContent[c.line].size]
    end
  end

  public
  #
  # Function to insert a diff in the diffHistory
  # Discards old diff if you undo some and then creates a new diff
  #
  def insertDiff change
    @diffHistoryPosition = 0 if @diffHistoryPosition < 0
    if @diffHistoryPosition != 0
      @diffHistory = @diffHistory.drop @diffHistoryPosition
      @diffHistoryPosition = 0
    end
    @diffHistory.insert(0, change)
    if @diffHistory.size > @workingUsers.size * 100
      @diffHistory.delete @diffHistory.last
    end
    nil
  end

  public
  #
  # Function to undo the last change in the buffer
  #
  def undo cursor
    if @diffHistoryPosition < @diffHistory.size
      @diffHistoryPosition = 0 if @diffHistoryPosition < 0
      diff = @diffHistory[@diffHistoryPosition]
      Diff::LCS.patch!(@fileContent, diff.diff)
      cursor.moveToLine diff.cursorBefore[0]
      cursor.moveToColumn diff.cursorBefore[1]
      @diffHistoryPosition += 1
      return #whatever we want
    end
    return #whatever we want but not the same as above
  end

  public
  #
  # Function to redo the last undo in the buffer
  #
  def redo cursor
    if @diffHistoryPosition > 0
      diff = @diffHistory[@diffHistoryPosition - 1]
      Diff::LCS.unpatch!(@fileContent, diff.diff)
      cursor.moveToLine diff.cursorAfter[0]
      cursor.moveToColumn diff.cursorAfter[1]
      @diffHistoryPosition -= 1
      return #whatever we want
    end
    return #whatever we want but not the same as above
  end

  private
  def splitText text
    res = Array.new(text.count("\n") + 1) {String.new}
    i = 0
    text.each_char do |c|
      if c == "\n"
        i += 1
      else
        res[i] << c
      end
    end
    res
  end

end
