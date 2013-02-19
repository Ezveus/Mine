#!/usr/bin/env ruby

#
# This class is an overlay of the String class
# It adds facilities to manage the lock in any buffer
#
module Mine
  class LockString < String
    
    #
    # Initializes the LockString
    #  - content is used to initialize the String
    #  - if the LockString is locked or not at it construction
    #
    def initialize content = "", locked = nil
      super content
      @locked = locked
    end

    #
    # Locks the LockString by the user
    #
    def lock user
      @locked = user
    end

    #
    # Unlocks the LockString
    #
    def unlock
      @locked = nil
    end

    #
    # Checks if the LockString is locked or not
    #
    def isLock?
      @locked != nil
    end

  end
end
