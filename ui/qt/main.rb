#!/usr/bin/env ruby

require 'Qt'
require './gui.rb'

app = Qt::Application.new ARGV
gui = Gui.new ARGV[0]

gui.show
app.exec
