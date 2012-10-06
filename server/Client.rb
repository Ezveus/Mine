#!/usr/bin/env ruby

require 'eventmachine'
require 'evma_httpserver'

load "server/Constant.rb"
load "server/Protocol.rb"
load "server/Userdb.rb"
load "server/Webclient.rb"

class Client < EM::Connection
  attr_accessor :userdb
  attr_reader :user

  include EM::HttpServer
  include Protocol

  @@clients = []

  def initialize *args
    super *args

    @authenticated = false
    @user = nil
    @userdb = Userdb.new
    @@clients << self
    @isWebClient = false
  end

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    puts "Received new response"
    response = EM::DelegatedHttpResponse.new self
    response.content_type 'text/plain'
    response.status = Constant::Ok
    response.content = getResponse response
    response.send_response
  end

  def user= user
    @user = user
    @authenticated = true if @user
    @authenticated = false unless @user
  end

  def exit exitType
    if exitType == :signalCatch
      puts "Sending exit message"
      puts "Sent"
    else
      puts "Doing what we can do"
    end
  end

  def self.clients
    @@clients
  end

  private

  def getDebug
    res = "http_protocol => #{@http_protocol}\n"
    res += "http_request_method => #{@http_request_method}\n"
    res += "http_cookie => #{@http_cookie}\n"
    res += "http_if_none_match => #{@http_if_none_match}\n"
    res += "http_content_type => #{@http_content_type}\n"
    res += "http_path_info => #{@http_path_info}\n"
    res += "http_request_uri => #{@http_request_uri}\n"
    res += "http_query_string => #{@http_query_string}\n"
    res += "http_post_content => #{@http_post_content}\n"
    res += "http_headers => #{@http_headers}\n"
    return res
  end

  def getResponse response
    return Constant::Fail if unvalidRequest? response
    return Constant::Fail if unknownRequest? response
    return Webclient.dealWithWebClient response, {:uri => @http_request_uri, :requestType => @http_request_method, :queryString => @http_query_string, :postContent => @http_post_content} if @isWebClient
    key = @http_post_content.split('=')[0].to_sym
    Commands[key].call @http_post_content, response, self
  end

  def unvalidRequest? response
    if @http_protocol != "HTTP/1.1" or @http_request_method != "POST" or @http_request_uri != "/mine/protocol/request" or @http_content_type != "application/x-www-form-urlencoded"
      @isWebClient = webclient? response
      unless @isWebClient
        $stderr.puts "Error : Unvalid request : bad HTTP format"
        response.status = Constant::UnvalidRequest
        return true
      end
    end
    if !@isWebClient and (@http_post_content =~ /.+={.*}/) != 0
      $stderr.puts "Error : Unvalid request : bad MINEP format"
      response.status = Constant::UnvalidRequest
      return true
    end
    false
  end

  def unknownRequest? response
    if !@isWebClient and !Requests.index @http_post_content.split('=')[0]
      $stderr.puts "Error : Unknown request"
      response.status = Constant::UnknownRequest
      return true
    end
    false
  end

  def webclient? response
    puts "Requested URI : #{@http_request_uri}"
    if (@http_request_uri =~ /^\/mine.*/)
      return false
    end
    true
  end
end
