module MineClient
  class Form
    attr_reader :index, :widgets, :rbc_form

    def initialize win
      @rbc_form = RubyCurses::Form.new win do
        modified = true
      end
    end

    def init_widgets mine_widgets
      self.widgets = mine_widgets
      @index = 0
    end

    # This function writes a character.
    def write ch
      @rbc_form.handle_key ch
      @widgets[@index].update_text
    end

    # This function returns a Mine Widget.
    def widgets
      @widgets
    end

    # This function initialises the Mine Widget tab.
    def widgets= mine_widgets
      @widgets = []
      mine_widgets.each do |widget|
        self.add_widget widget
      end
    end

    # This function returns the corresponding Mine Widget.
    def [] i
      @widgets[i]
    end

    # This function updates the corresponding Mine Widget.
    def []= i, widget
      self.init_widget
      @widgets[i] = widget
    end

    # This function adds a Mine Widget.
    def add_widget widget
      self.init_widget widget
      @widgets << widget
    end

    # This function adds a Mine Widget at the index i.
    # If the index is greater than the Widget tab size,
    # it add it at the end
    def add_widget_at widget, i
      self.init_widget widget
      if i > @widgets.length
        @widgets << widget
      else
        res = []
        @widgets.each_index do |index|
          res << elem if index == i
          res << @widgets[index]
        end
        @widgets = res
      end
    end

    # This function deletes a Mine Widget
    def delete_widget widget
      @widgets.delete widget
    end

    # This function deletes the Mine Widget at the corresponding index
    def delete_widget_at i
      @widgets.delete_at i
    end

    # This function returns the Mine Widget which corresponds to the given hash.
    # Returns nil if fails.
    def find_widget widget_description
      @widgets.find widget_description
    end

    # This function returns an Array of the Mine Widgets
    # which correspond to the given hash.
    # Returns nil if fails.
    def find_widgets widgets_description
      @widgets.find_all widgets_description
    end

    # This function returns the index of the Mine Widget
    # which corresponds to the given hash.
    # Returns nil if fails.
    def find_widget_index widget_description
      @widgets.find_index widget_description
    end

    # This function returns an Array of the index of the Mine Widgets
    # which correspond to the given hash.
    # Returns nil if fails.
    def find_widgets_index widgets_description
      @widgets.find_index_all widgets_description
    end

    # This function resizes a widget.
    def resize width, height
      @widgets[@index].width = width
      @widgets[@index].height = height
      @widgets[@index].repaint
    end

    #private

    # This function initializes a widget and bind
    def init_widget widget
      widget.init
      widget.bind if widget.bindings
    end
  end
end
