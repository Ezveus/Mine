#!/usr/bin/env ruby

module Mine
  module Shell
    def self.mkdir args, response, client
      puts "Go fuck yourself with a cactus"
    end

    def self.rmdir args, response, client
      puts "Go fuck yourself with pieces of glass"
    end

    def self.rm args, response, client
      puts "Go fuck yourself with a zeppelin"
    end

    def self.tree args, response, client
      puts "Go fuck yourself with a macbook"
    end

    def self.cp args, response, client
      puts "Go fuck yourself with a 27\" flat screen"
    end

    def self.touch args, response, client
      puts "Go fuck yourself with a pumpkin"
    end

    def self.mv args, response, client
      puts "Go merge your head and your anus"
    end

    ShellCommands ||= {
      "Mkdir".to_sym => Proc.new { |args, response, client| self.mkdir args, response, client },
      "Rmdir".to_sym => Proc.new { |args, response, client| self.rmdir args, response, client },
      "Rm".to_sym => Proc.new { |args, response, client| self.rm args, response, client },
      "Tree".to_sym => Proc.new { |args, response, client| self.tree args, response, client },
      "Cp".to_sym => Proc.new { |args, response, client| self.cp args, response, client },
      "Touch".to_sym => Proc.new { |args, response, client| self.touch args, response, client },
      "Mv".to_sym => Proc.new { |args, response, client| self.mv args, response, client }
  end
end
