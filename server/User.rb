#!/usr/bin/env ruby

load "server/Userdb.rb"
load "server/Frame.rb"

class User
  attr_reader :userInfo, :frames, :cmdHistory, :killRing

  def initialize username, userdb
    @clients = []
    @cmdHistory = []
    @killRing = []
    @killRingPosition = 0
    @frames = {}
    @userInfo = userdb.selectUser username
  end

  def to_s
    @userInfo.to_s
  end

  def addCmdToHistory cmd
    @cmdHistory.insert(0, cmd)
    if @cmdHistory.size > 100
      @cmdHistory.delete @cmdHistory.last
    end
    nil
  end

  public
  def killLine buffer
    if @frames[buffer].lastCmd.start_with? "kill"
      killLineConcat buffer
    else
      killLineNewEntry buffer
    end
    @killRingPosition = 0
  end

  private
  def killLineConcat buffer
    c = @frames[buffer].cursor
    if c.isAtEOL?
      size = 1
      @killRing[0] << "\n"
    else
      @killRing[0] << buffer.fileContent[c.line][c.column,
                                                 buffer.fileContent[c.line].size]
      size = buffer.fileContent[c.line][c.column,
                                        buffer.fileContent[c.line].size].size
    end
    @frames[buffer].deleteBuffer buffer, size
  end

  def killLineNewEntry buffer
    c = @frames[buffer].cursor
    @killRing.insert 0, buffer.fileContent[c.line][c.column,
                                                   buffer.fileContent[c.line].size]
    @killRing[0] = "\n" if @killRing[0] == ""
    @frames[buffer].deleteBuffer buffer, @killRing[0].size
  end
end
