#!/usr/bin/env ruby

class Buffer
  def initialize fileLocation, fileName, serverSide
    @fileLocation = fileLocation
    @fileName = fileName
    @id = Random.rand.to_i
    @rights = {}
    @serverSide = serverSide
    @workingUsers = []
    @fileContent = File.new(@fileLocation + @fileName).readlines.join
  end
end
