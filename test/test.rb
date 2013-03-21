#!/usr/bin/env ruby
## test.rb for project Mine Tests
## 
## Made by Matthieu Ciappara
## Mail : <ciappam@gmail.com>
## 
## Started by Matthieu Ciappara on Sun Mar  3 12:36:13 2013
##

module Mine
  class Test
    def initialize testnames, blocks
      @testnames = testnames
      @testresults = []
      if @testnames.length == blocks.length
        @testnames.each_index do |i|
          @success = []
          @failures = []
          @i = i
          puts "\033[34mTesting #{@testnames[i]} :\033[0m"
          blocks[i].call self
          @testresults << self.end
        end
        puts "\n>>> Reporting :"
        if @testresults.length > 1
          @testresults.each do |test|
            self.report test
          end
        end
      else
        raise "The number of tests and names are different"
      end
    end

    def assert name, test, reason = nil
      ret = false
      printf "\033[34m#{name} : "
      printf "#{reason} : " if reason
      if test
        success name
      else
        failure name
      end
    end

    def shouldSuccess name, test
      assert name, test
    end

    def shouldFail name, test, reason = nil
      assert name, !test, reason
    end

    def success name
      puts "\033[32mV\033[0m"
      @success << name
      true
    end

    def failure name
      puts "\033[31mX\033[0m"
      @failures << name
      false
    end

    def end
      puts "\033[34m#{@testnames[@i]} :"
      puts "\t\033[32m#{@success.length} passed"
      puts "\t\033[31m#{@failures.length} failed"
      puts "\033[0m"
      { :name => @testnames[@i],
        :success => @success.length,
        :failures => @failures.length }
    end

    def report test
      puts "\033[34m#{test[:name]} :"
      puts "\t\033[32m#{test[:success]} passed"
      puts "\t\033[31m#{test[:failures]} failed"
      puts "\033[0m"
    end
  end
end
