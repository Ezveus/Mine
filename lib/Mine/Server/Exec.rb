#!/usr/bin/env ruby

module Mine
  module Exec
    #
    # the following methods are called when the user request a specific action
    #
    def self.killLine buffer, args, response, client
      client.user.killLine buffer
    end

    def self.yank buffer, args, response, client
      client.user.yank buffer
    end

    def self.yankPop buffer, args, response, client
      client.user.yankPop buffer
    end

    def self.overWriteMode buffer, args, response, client
      client.user.switchOverwrite buffer
    end

    def self.killBuffer buffer, args, response, client
      client.user.killBuffer buffer
    end

    def self.undo buffer, args, response, client
      client.user.undo buffer
    end

    def self.redo buffer, args, response, client
      client.user.redo buffer
    end

    def self.writeDistantFile buffer, args, response, client
      status = client.user.writeDistantFile buffer, args
      if status == Constant::Fail
        Log::Client.error "no such directory"
        response.status = Constant::PathError
        return Constant::Fail
      end
      Constant::Success
    end

    def self.saveDistantFile buffer, args, response, client
      status = client.user.saveDistantFile buffer, args, response
      if status == Constant::Fail
        Log::Client.error "No such file"
        return status
      end
      Constant::Success
    end

    # hash acting as a dispatcher for the above commands
    ExecCommands ||= {
      "KillLine".to_sym => Proc.new { |buffer, args, response, client| self.killLine buffer, args, response, client },
      "Yank".to_sym => Proc.new { |buffer, args, response, client| self.yank buffer, args, response, client },
      "YankPop".to_sym => Proc.new { |buffer, args, response, client| self.yankPop buffer, args, response, client },
      "OverWriteMode".to_sym => Proc.new { |buffer, args, response, client| self.overWriteMode buffer, args, response, client },
      "KillBuffer".to_sym => Proc.new { |buffer, args, response, client| self.killBuffer buffer, args, response, client },
      "Undo".to_sym => Proc.new { |buffer, args, response, client| self.undo buffer, args, response, client },
      "Redo".to_sym => Proc.new { |buffer, args, response, client| self.redo buffer, args, response, client },
      "WriteDistantFile".to_sym => Proc.new { |buffer, args, response, client| self.writeDistantFile buffer, args, response, client },
      "SaveDistantFile".to_sym => Proc.new { |buffer, args, response, client| self.saveDistantFile buffer, args, response, client }
    }
  end
end
