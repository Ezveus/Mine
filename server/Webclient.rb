# -*- coding: utf-8 -*-
require 'eventmachine'
require 'evma_httpserver'

load "server/HTTP.rb"

module Webclient
  def self.dealWithWebClient response, httpInfos
    response.status = 200
    getHeaders response
    response.content = getContent response, httpInfos
  end

  private

  def self.getContent response, httpInfos
    httpInfos[:uri] = "./ui/webclient/index.html" if httpInfos[:uri] == "/"
    httpInfos[:uri][/^\//] = "./ui/webclient/" if httpInfos[:uri] != "./ui/webclient/index.html"
    begin
      return File.new(httpInfos[:uri]).read
    rescue Errno::ENOENT
      return HTTP.error404 response, httpInfos
    end
    httpInfos.each do |key, value|
      puts "httpInfos[#{key}] = #{value}"
    end
  end

  def self.getHeaders response
    puts "response.headers = #{response.headers}"
    response.headers["Content-type"] = "text/html"
  end
end
