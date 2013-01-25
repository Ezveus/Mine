#!/usr/bin/env ruby

require 'diff/lcs'
require 'json'

#
# Class to stock the diff made by Diff::LCS.diff
#
module Mine
  class Change
    attr_reader :cursorBefore, :cursorAfter, :user, :diff

    def initialize user, cursorBefore, cursorAfter, diff
      @diff = diff[0]
      @user = user
      @cursorBefore = cursorBefore
      @cursorAfter = cursorAfter
    end

    def to_request bufferId
      reqargs = {
        "buffer" => bufferId,
        "user" => @user.userInfo.name,
        "cursorBefore" => @cursorBefore,
        "cursorAfter" => @cursorAfter,
        "diff" => @diff.to_a
      }
      "SYNC=#{JSON.dump reqargs}"
    end
  end
end
