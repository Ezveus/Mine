require 'rbcurse/core/widgets/rwidget'

module Mine
  class Widget
    attr_accessor :x, :y, :width, :height, :text, :editable, :focusable

    def initialize(x = 0, y = 0, width = max_x, height = max_y, text = nil)
      @x = x
      @y = y
      @width = width
      @height = height
      @text = text
      @editable = true
      @focusable = true
      @bindings = []
    end

    # This function add a binding to the Binding tab if the binding does not exist.
    # If the binding exists (if another binding has the same name),
    # it replace it by the new one.
    def << binding
      @bindings = [binding] + @bindings
      @bindings = @bindings.uniq { |binding| binding.call }
    end

    # This function remove a binding from the Binding tab.
    # The parameter must be the name of the Binding object.
    def >> b
      @bindings.delete_if { |binding| binding.call == b }
    end

    def bindings
      @bindings
    end

    def bindings= bindings_tab
      @bindings = bindings_tab.uniq { |binding| binding.call }
    end

    def max_x
      Window.instance.max_x
    end

    def max_y
      Window.instance.max_y
    end

    def bind
    end

    def repaint
    end

    def update_text
    end

    private
    def get_text
      return @text unless @text.class == 'String'.class
      res = []
      @text.each_line { |line| res << line }
      res << ""
      @text = res
    end
  end
end
