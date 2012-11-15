#!/usr/bin/env ruby

#
# This class is an overlay of the String class
# It adds facilities to manage the lock in any buffer
#

class LockString < String
  
  #
  # Initializes the LockString
  #  - content is used to initialize the String
  #  - if the LockString is locked or not at it construction
  #
  def initialize content, locked = false
    super content
    @locked = locked
  end

  #
  # Locks the LockString
  #
  def lock
    @locked = true
  end

  #
  # Unlocks the LockString
  #
  def unlock
    @locked = false
  end

  #
  # Checks if the LockString is locked or not
  #
  def isLock?
    @locked
  end

end
