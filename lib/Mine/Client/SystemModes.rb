MineClient.init_fbuffers

if MineClient.fbuffers.empty?
  puts "usage:./mine file"
  exit
end

MineClient.window

require 'SystemModes/fundamentalMode'
