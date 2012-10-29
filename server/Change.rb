#!/usr/bin/env ruby

require 'diff/lcs'

class Change < Diff::LCS::Change
  attr_reader :cursorBefore, :cursorAfter, :user

  def initialize user, cursorBefore, cursorAfter, diff
    super diff.action, diff.position, diff.element
    @user = user
    @cursorBefore = cursorBefore
    @cursorAfter = cursorAfter
  end
end
