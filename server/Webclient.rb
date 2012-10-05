# -*- coding: utf-8 -*-
require 'eventmachine'
require 'evma_httpserver'

module Webclient
  def self.dealWithWebClient response, httpInfos
    response.status = 200
    response.headers = getHeaders response
    response.content = getContent response, httpInfos
  end

  private

  def self.getContent response, httpInfos
    httpInfos[:uri] = "./ui/webclient/index.html" if httpInfos[:uri] == "/"
    httpInfos[:uri][/^\//] = "./ui/webclient/" if httpInfos[:uri] != "./ui/webclient/index.html"
    # lire le fichier demandé
    httpInfos.each do |key, value|
      puts "httpInfos[#{key}] = #{value}"
    end
    "OK"
  end

  def self.getHeaders response
    puts "response.headers = #{response.headers}"
    response.headers
  end
end
