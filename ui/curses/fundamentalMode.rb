load 'MineTextArea.rb'

# Get fbuffers
buffers = Mine.fbuffers

# Create a Mine TextArea and set its buffer
text_area = Mine::TextArea.new
text_area.text = buffers[0]

# Create bindings for the Mine TextArea
text_area << Mine::Binding.new([?\C-x, ?\C-c], 'exit')
text_area << Mine::Binding.new([?\C-x, ?\C-s], 'save')
text_area << Mine::Binding.new(Mine::Key::RESIZE, 'resize')

# init Widgets tab
@widgets = [text_area]
