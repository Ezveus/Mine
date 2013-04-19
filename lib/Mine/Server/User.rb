#!/usr/bin/env ruby

#
# Class to manage all the operations a user can do
#
module Mine
  class User
    attr_reader :userInfo, :frames, :cmdHistory, :killRing, :dir
    attr_accessor :lastClient, :clients

    # class variable giving access to all the user logged
    @@users = {}

    def self.getInstance username, client
      user = @@users[username]
      if user.nil?
        user = User.new username, client
        @@users[username] = user
        user
      else
        user.clients << client
        user
      end
    end

    #
    # Initializes the user with
    #  - it's username
    #  - the client that connected the user to the server
    #
    def initialize username, client
      @clients = [client]
      @cmdHistory = []
      @killRing = []
      @killRingPosition = 0
      @frames = {}
      @userInfo = client.userdb
      @lastClient = client
      @dir = "#{client.userdir}/#{@userInfo.name}"
      unless Dir.exist? @dir
        Dir.mkdir @dir, 0700
      end
    end

    #
    # Method to call to get a string representation of the user
    #
    def to_s
      @userInfo.to_s
    end

    #
    # Method to call when needed to update any information to the clients of the user
    #
    def updateClients request
      @clients.each do |client|
        unless client == @lastClient
          client.socket.write request
        end
      end
    end

    #
    # Method called when a new frame is to be created
    #
    def addFrame fileLocation, fileName, fileContent, rights, serverSide, line, overWrite = false
      buf = nil
      @frames.each do |buffer, frame|
        if buffer.fileLocation == fileLocation
          buf = buffer
          break
        end
      end
      if buf.nil?
        addFrameNewBuffer fileLocation, fileName, fileContent, rights, serverSide, line
      else
        addFrameExistingBuffer buf, line, overWrite
      end
    end

    #
    # Method to call when a new file is opened by the user
    #
    def addFrameNewBuffer fileLocation, fileName, fileContent, rights, serverSide, line, overWrite = false
      buffer = Buffer.new(fileLocation, fileName, fileContent,
                          rights, serverSide, self)
      cursor = Cursor.new(self, buffer.fileContent, line)
      frame = Frame.new(cursor, overWrite)
      @frames[buffer] = frame
      buffer.id
    end

    #
    # Method to call when a user joins an other user to edit a buffer already opened
    #
    def addFrameExistingBuffer buffer, line, overWrite
      cursor = Cursor.new(self, buffer.fileContent, line)
      frame = Frame.new(cursor, overWrite)
      buffer.addWorkingUser self
      @frames[buffer] = frame
      buffer.id
    end

    #
    # Method used to find a specific buffer
    #
    def findBuffer bufferid
      buf = nil
      @frames.each do |buffer, frame|
        if bufferid == buffer.id
          buf = buffer
          break
        end
      end
      buf
    end

    #
    # Method used to close a buffer
    #
    def killBuffer buffer
      @frames.delete buffer
    end

    #
    # Method to call to switch on/off the overWrite mode
    #
    def swithOverwrite buffer
      @frames[buffer].switchOverWrite
    end

    #
    # Method to call to insert text on a given buffer
    #
    def insert buffer, text
      @frames[buffer].fillBuffer buffer, text
    end

    #
    # Method to call to delete text using backspace on a given buffer
    #
    def backspace buffer, nb
      @frames[buffer].backspaceBuffer buffer, nb
    end

    #
    # Method to call to delete text using delete on a given buffer
    #
    def delete buffer, nb
      @frames[buffer].deleteBuffer buffer, nb
    end

    #
    # Method to call to move the cursor in any direction in a given buffer
    #
    def moveCursor buffer, direction, nb
      @frames[buffer].moveCursor direction, nb
    end

    #
    # Method to call to undo the last change on a given buffer
    #
    def undo buffer
      @frames[buffer].undo buffer
    end

    #
    # Method to call to redo the last undone change on a given buffer
    #
    def redo buffer
      @frames[buffer].redo buffer
    end

    #
    # Method to call everytime an EXEC command is received
    #
    def addCmdToHistory cmd
      @cmdHistory.insert(0, cmd)
      if @cmdHistory.size > 100
        @cmdHistory.delete @cmdHistory.last
      end
      nil
    end

    public
    #
    # Method to yank a line or multiple lines
    #
    def yank buffer
      @frames[buffer].switchOverWrite if overwrite = @frames[buffer].isOverWrite?
      @frames[buffer].fillBuffer buffer, @killRing[0]
      @frames[buffer].switchOverWrite if overwrite
      @frames[buffer].updateLastCmd "Yank"
    end

    public
    #
    # Method to unfold the killRing
    #
    def yankPop buffer
      if @frames[buffer].lastCmd.start_with? "Yank"
        # some initialization for the diff insertion
        cursor = @frames[buffer].cursor
        bufferBefore = Array.new(buffer.fileContent)
        cursorBefore = [cursor.line, cursor.column]

        # the piece o really interresting code here
        @frames[buffer].backspaceBuffer buffer, @killRing[@killRingPosition].size, false
        if @killRingPosition < @killRing.size
          @killRingPosition += 1
        else
          @killRingPosition = 0
        end
        @frames[buffer].fillBuffer buffer, @killRing[@killRingPosition]
        # the end of the diff management
        bufferAfter = Array.new(buffer.fileContent)
        cursorAfter = [@cursor.line, @cursor.column]
        d = Diff::LCS.diff(bufferAfter, bufferBefore)
        diff = Change.new(self, cursorBefore, cursorAfter, d)
        buffer.insertDiff diff
      end
      @frames[buffer].updateLastCmd "YankPop"
    end

    public
    #
    # Method to manage the killing of line (aka C-k)
    #
    def killLine buffer
      if @frames[buffer].lastCmd.start_with? "Kill"
        killLineConcat buffer
      else
        killLineNewEntry buffer
      end
      @frames[buffer].updateLastCmd "KillLine"
      @killRingPosition = 0
    end

    private
    #
    # Bunch of methods to manage the killLine
    #
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

    public
    #
    # Method used to "save as" a file on the server side
    #
    def writeDistantFile buffer, args
      path = "#{@dir}/#{args[0]}"
      begin
        f = File.new path, "w"
      rescue
        return Constant::Fail
      end
      f.write buffer.to_file
      f.close
      Constant::Success
    end

    public
    #
    # Method used to save a file on the server side
    #
    def saveDistantFile buffer, args, response
      unless buffer.serverSide
        response.status = Constant::ServerFile
        return Constant::Fail
      end
      begin
        f = File.new buffer.fileLocation "w"
      rescue
        response.status = PathError
        return Constant::Fail
      end
      f.write buffer.to_file
      f.close
      Constant::Success
    end

  end
end
