# Gets fbuffers
buffers = MineClient.fbuffers
file = MineClient.file(0)

# Creates a MineClient TextArea and set its buffer
text_area = MineClient::TextArea.new
text_area.text = buffers[0]
text_area.title = file

# Creates bindings for the MineClient TextArea
text_area << MineClient::Binding.new([?\C-x, ?\C-c], 'exit')
text_area << MineClient::Binding.new([?\C-x, ?\C-s], 'save')
text_area << MineClient::Binding.new(MineClient::Key::RESIZE, 'resize')

# Inits Widgets tab
@widgets = [text_area]
