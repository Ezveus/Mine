#!/usr/bin/env ruby

require 'diff/lcs'

class Change
  attr_reader :cursorBefore, :cursorAfter, :user

  def initialize user, cursorBefore, cursorAfter, diff
    @diff = Diff::LCS.__normalize_patchset diff
    @user = user
    @cursorBefore = cursorBefore
    @cursorAfter = cursorAfter
  end
end
