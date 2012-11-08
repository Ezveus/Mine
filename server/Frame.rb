#!/usr/bin/env ruby

require 'diff/lcs'
load 'server/Cursor.rb'
load 'server/Change.rb'
load 'server/Buffer.rb'

#
# Class that links the User to the Buffer
# This class makes call the functions of the buffer to apply the changes
#

class Frame
  attr_reader :cursor, :overWrite

  #
  # Initializes the class with :
  #  - the user's cursor on the associated buffer
  #  - wether or not is the overWrite mode on
  #  - stocks the last command applied to the buffer by the user
  #
  def initialize cursor, overWrite = false
    @cursor = cursor
    @overWrite = overWrite
    @lastCmd = ""
  end

  #
  # Function to know if the overWrite mode is on or not
  #
  def isOverWrite? 
    @overWrite
  end

  #
  # Function to switch the overWrite mode on or off
  #
  def switchOverWrite
    @overWrite = !@overWrite
  end

  #
  # Function to insert text in the given buffer
  # Also creates a diff
  #
  def fillBuffer buffer, text
    bufferBefore = Array.new(buffer.fileContent)
    cursorBefore = [@cursor.line, @cursor.column]
    if isOverWrite?
      buffer.overwriteText @cursor, text
    else
      buffer.insertText @cursor, text
    end
    bufferAfter = Array.new(buffer.fileContent)
    cursorAfter = [@cursor.line, @cursor.column]
    d = Diff::LCS.diff(bufferAfter, bufferBefore)
    diff = Change.new(@cursor.owner, cursorBefore, cursorAfter, d)
    buffer.insertDiff diff
    # call the method to update the clients
  end

  #
  # Function to delete text in the given buffer
  # This one is to call when you type backspace
  # Also creates a diff
  #
  def backspaceBuffer buffer, nb
    bufferBefore = Array.new(buffer.fileContent)
    cursorBefore = [@cursor.line, @cursor.column]
    buffer.deleteTextBackspace @cursor, nb
    bufferAfter = Array.new(buffer.fileContent)
    cursorAfter = [@cursor.line, @cursor.column]
    d = Diff::LCS.diff(bufferAfter, bufferBefore)
    diff = Change.new(@cursor.owner, cursorBefore, cursorAfter, d)
    buffer.insertDiff diff
    # call the method to update the clients
  end

  #
  # Function to delete text in the given buffer
  # This one is to call when you type delete
  # Also creates a diff
  #
  def deleteBuffer buffer, nb
    bufferBefore = Array.new(buffer.fileContent)
    cursorBefore = [@cursor.line, @cursor.column]
    buffer.deleteTextDelete @cursor, nb
    bufferAfter = Array.new(buffer.fileContent)
    cursorAfter = [@cursor.line, @cursor.column]
    d = Diff::LCS.diff(bufferAfter, bufferBefore)
    diff = Change.new(@cursor.owner, cursorBefore, cursorAfter, d)
    buffer.insertDiff diff
    # call the method to update the clients
  end

  #
  # Moves the cursor in the given direction
  # The second argument is ignored if :origin or :end are passed first
  #
  def moveCursor direction, nb = 1
    cursorPosition = case direction
                     when :up then @cursor.moveUp nb
                     when :right then @cursor.moveRight nb
                     when :down then @cursor.moveDown nb
                     when :left then @cursor.moveLeft nb
                     when :origin then @cursor.moveToOrigin
                     when :end then @cursor.moveToEnd
                     else [@cursor.line, @cursor.column]
                     end
    cursorPosition
  end
end
