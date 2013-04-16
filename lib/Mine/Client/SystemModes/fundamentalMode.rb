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

# #Create a Label which will be associated with the Login Field
# login_label = MineClient::Label.new('Login : ')
# passwd_label = MineClient::Label.new('Password : ')

# # Creates a MineClient Field
# field_height = 1
# lfield = MineClient::Field.new(2, MineClient::Window.instance.max_height - (field_height + 3),
#                                25, field_height, login_label)
# pfield = MineClient::Field.new(2, MineClient::Window.instance.max_height - (field_height + 1),
#                                25, field_height, passwd_label)

# Inits Widgets tab
@widgets = [text_area]

