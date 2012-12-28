load 'MineWidget.rb'
require 'rbcurse/core/widgets/rtextarea'

module Mine
  class TextArea < Widget
    attr_accessor :title, :title_attrib, :borders

    def initialize(x = 0, y = 0, width = max_width,
                   height = max_height, title = nil, text = nil)
      super(x, y, width, height, text)
      @title = title
      @title_attrib = nil
      @borders = true
    end

    # Inits a Mine TextArea
    def init
      y = @y
      x = @x
      width = @width
      height = @height
      title = @title
      list = get_text
      title_attrib = @title_attrib
      borders = @borders
      editable = @editable
      focusable = @focusable
      @rbc_text_area = RubyCurses::TextArea.new Mine.window.form do
        row y
        col x
        width width
        height height
        title title
        list list
        title_attrib title_attrib
        suppress_borders (not borders)
        editable editable
        focusable focusable
      end
      @rbc_text_area.repaint
      true
    end

    # Repaints the widget
    def repaint
      @rbc_text_area.print_borders
      @rbc_text_area.set_modified
      @rbc_text_area.repaint
    end

    # Binding
    def bind
      @bindings.each do |b|
        @rbc_text_area.bind_key b.key do
          (b.call).call
        end
      end
    end

    def update_text
      @text = @rbc_text_area.list
    end

    def width= w
      @width = w
      @rbc_text_area.width = w
    end

  end
end

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
  end
end
