require 'Qt'

class CentralWidget < Qt::Widget

  slots 'save()'

  def initialize fileName
    super()
    @textEdit = Qt::TextEdit.new
    @fileName = fileName
    @grid = Qt::GridLayout.new

    @grid.addWidget @textEdit, 0, 0

    setLayout @grid
    initTextEdit
  end

  def save()
    if @fileName
      file = File.new @fileName, "w"
      file.puts @textEdit.toPlainText
      file.close
    end
  end

  def load
    if @fileName and File.exists? @fileName
      file = File.new @fileName
      @textEdit.setText file.read
      file.close
    end
  end

  def initTextEdit
    load
  end
end
