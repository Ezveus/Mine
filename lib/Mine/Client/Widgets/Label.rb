module MineClient
  class Label < Widget
    attr_accessor :color

    def initialize(text, x = 0, y = 0)
      return nil unless text
      super(x, y, text.length + 2, 1, text)
      @color = nil
    end

    def init
      y = @y
      x = @x
      width = @width
      height = @height
      text = @text
      editable = @editable
      focusable = @focusable
      color = @color
      @rbc_label = RubyCurses::Label.new MineClient.window.form do
        row y
        col x
        width width
        height height
        text text
        color color
        #        suppress_borders (not borders)
        #        editable editable
        focusable focusable
      end
      @rbc_label.repaint
      true
    end

    def refresh
      @rbc_label.repaint
    end
  end
end
