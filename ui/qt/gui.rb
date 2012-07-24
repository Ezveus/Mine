require 'Qt'
require './centralWidget.rb'

# class FileMenu < Qt::Menu
# end

# class EditMenu < Qt::Menu
# end

# class OptionsMenu < Qt::Menu
# end

# class BuffersMenu < Qt::Menu
# end

# class ToolsMenu < Qt::Menu
# end

# class HelpMenu < Qt::Menu
# end

class Gui < Qt::MainWindow
  def initialize fileName
    super()

    @centralWidget = CentralWidget.new fileName
    # @fileMenu = FileMenu.new
    # @editMenu = EditMenu.new
    # @optionsMenu = OptionsMenu.new
    # @buffersMenu = BuffersMenu.new
    # @toolsMenu = ToolsMenu.new
    # @helpMenu = HelpMenu.new

    initAction
    initMenu
    setCentralWidget(@centralWidget)
  end

  def initAction
    @saveAct = Qt::Action.new "Save", self
    connect @saveAct, SIGNAL(:triggered), @centralWidget, SLOT(:save)
    @saveAct.shortcut = Qt::KeySequence.new "Ctrl+S"
    @saveAct.statusTip = "Save"

    @quitAct = Qt::Action.new "Quit", self do
      connect (SIGNAL :triggered) { $qApp.quit }
    end
    @quitAct.shortcut = Qt::KeySequence.new "Ctrl+Q"
    @quitAct.statusTip = "Quit"
  end

  def initMenu
    @fileMenu = menuBar().addMenu("&File")
    @fileMenu.addAction @saveAct
    @fileMenu.addSeparator
    @fileMenu.addAction @quitAct
  end
end
