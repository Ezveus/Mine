#!/usr/bin/env ruby

require 'eventmachine'
require 'evma_httpserver'

load "server/Constant.rb"
load "server/Protocol.rb"
load "server/Userdb.rb"

class Client < EM::Connection
  attr_accessor :userdb
  attr_accessor :user

  include EM::HttpServer
  include Protocol

  def initialize *args
    super *args

    @authenticated = false
    @user = nil# user
    @userdb = Userdb.new
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
    key = @http_post_content.split('=')[0].to_sym
    Commands[key].call @http_post_content, response, self
  end

  def unvalidRequest? response
    if @http_protocol != "HTTP/1.1" or @http_request_method != "POST" or @http_path_info != "/mine/protocol/request" or @http_content_type != "application/x-www-form-urlencoded"
      response.status = Constant::UnvalidRequest
      return true
    end
    unless (@http_post_content =~ /.+={.*}/) == 0
      response.status = Constant::UnvalidRequest
      return true
    end
    false
  end

  def unknownRequest? response
    unless Requests.index @http_post_content.split('=')[0]
      response.status = Constant::UnknownRequest
      return true
    end
    false
  end
end
