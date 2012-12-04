module RubyCurses
  class TextArea < Widget
    def join_to_prev_line
      return -1 unless @editable
      return if (@current_index == 0 or not @curpos == 0)

      oldCurPos = @curpos
      oldCurIndex = @current_index
      str = @list[oldCurIndex]
      @current_index -= 1
      prevStr = @list[@current_index].chomp
      @curpos = prevStr.length

      if prevStr.length == 0
        delete_line @current_index
      else
        @list[@current_index] = prevStr + str unless str.length == 0
        delete_line @current_index + 1
      end

      maxLen = @maxlen || @width - @internal_width
      return if (spaceLeft = maxLen - str.length) == 0
      return unless (blankFound = @buffer.rindex(' ', spaceLeft))

      carryUp = @buffer[0 .. blankFound]
      fire_handler :CHANGE, InputDataEvent.new(oldCurPos, oldCurPos + carryUp.length,
                                               self, :DELETE, oldCurIndex, carryUp)
      fire_handler :CHANGE, InputDataEvent.new(@curpos, @curpos + carryUp.length,
                                               self, :INSERT, oldCurIndex - 1, carryUp)
    end
    def resize (w = FFI::NCurses.getmaxx(FFI::NCurses.stdscr),
                h = FFI::NCurses.getmaxy(FFI::NCurses.stdscr))
      width = w
      height = h
    end
  end
end


