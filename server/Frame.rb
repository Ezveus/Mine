#!/usr/bin/env ruby

require 'diff/lcs'
load 'server/Cursor.rb'
load 'server/Change.rb'
load 'server/Buffer.rb'

class Frame
  attr_reader :cursor, :overWrite

  def initialize cursor, overWrite = false
    @cursor = cursor
    @overWrite = overWrite
    @lastCmd = ""
  end

  def isOverWrite? 
    @overWrite
  end

  def switchOverWrite
    if @overWrite
      @overWrite = false
    else
      @overwrite = true
    end
  end

  def fillBuffer buffer, text
    bufferBefore = buffer.fileContent
    cursorBefore = [@cursor.line, @cursor.column]
    buffer.insertText @cursor, text
    buffer.deleteTextDelete @cursor, text.size if isOverWrite?
    bufferAfter = buffer.fileContent
    cursorAfter = [@cursor.line, @cursor.column] 
    diff = Change.new(@cursor.owner, cursorBefore, cursorAfter, 
                      Diff::LCS.diff(bufferBefore, bufferAfter))
    buffer.insertDiff diff
    # call the method to update the clients
  end

  def backspaceBuffer buffer, nb
    bufferBefore = buffer.fileContent
    cursorBefore = [@cursor.line, @cursor.column]
    buffer.deleteTextDelete @cursor, nb
    bufferAfter = buffer.fileContent
    cursorAfter = [@cursor.line, @cursor.column] 
    diff = Change.new(cursorBefore, cursorAfter, 
                      Diff::LCS.diff(bufferBefore, bufferAfter))
    buffer.insertDiff diff, @cursor.owner
    # call the method to update the clients
  end

  def deleteBuffer buffer, nb
    bufferBefore = buffer.fileContent
    cursorBefore = [@cursor.line, @cursor.column]
    buffer.deleteTextDelete @cursor, nb
    bufferAfter = buffer.fileContent
    cursorAfter = [@cursor.line, @cursor.column] 
    diff = Change.new(cursorBefore, cursorAfter, 
                      Diff::LCS.diff(bufferBefore, bufferAfter))
    buffer.insertDiff diff, @cursor.owner
    # call the method to update the clients
  end

  def moveCursor direction, nb
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
