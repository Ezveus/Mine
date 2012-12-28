#!/usr/bin/env ruby

require 'diff/lcs'

#
# Class to stock the diff made by Diff::LCS.diff
#
module Mine
  class Change
    attr_reader :cursorBefore, :cursorAfter, :user, :diff

    def initialize user, cursorBefore, cursorAfter, diff
      @diff = Diff::LCS.__normalize_patchset diff
      @user = user
      @cursorBefore = cursorBefore
      @cursorAfter = cursorAfter
    end
  end
end
