load 'MineTextArea.rb'

# Gets fbuffers
buffers = Mine.fbuffers
file = Mine.file(0)

# Creates a Mine TextArea and set its buffer
text_area = Mine::TextArea.new
text_area.text = buffers[0]
text_area.title = file

# Creates bindings for the Mine TextArea
text_area << Mine::Binding.new([?\C-x, ?\C-c], 'exit')
text_area << Mine::Binding.new([?\C-x, ?\C-s], 'save')
text_area << Mine::Binding.new(Mine::Key::RESIZE, 'resize')

# Inits Widgets tab
@widgets = [text_area]
