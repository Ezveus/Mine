module MineClient
  class Field < Widget
    attr_accessor :title, :title_attrib

    def initialize(x = 0, y = 0, width = max_width,
                   height = max_height, title = nil, text = nil)
      super(x, y, width, height, text)
      @title = title
      refresh_title if title
      @title_attrib = nil
    end

    def init
      label = RubyCurses::Label.new MineClient.window.form, {'text' => @title.text}
      @rbc_field = RubyCurses::Field.new MineClient.window.form, {
        row: @y,
        col: @x,
        width: @width,
        height: @height,
        title: @title,
        text: @text,
        editable: @editable,
        focusable: @focusable,
        set_label: label,
      }
      @rbc_field.repaint
      label.repaint
      true
    end

    def refresh_title
      @title.x = @x
      @title.y = @y
      @x = @title.width
    end
  end
end
