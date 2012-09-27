#!/usr/bin/env ruby

require 'eventmachine'
require 'evma_httpserver'

class Server < EM::Connection
  include EM::HttpServer

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new self
    response.status = 200
    response.content_type 'text/html'
    response.content = description_kikoo
    response.send_response
  end

  def description_kikoo 
    res = "http_protocol => #{@http_protocol}\n<br/>\n"
    res += "http_request_method => #{@http_request_method}\n<br/>\n"
    res += "http_cookie => #{@http_cookie}\n<br/>\n"
    res += "http_if_none_match => #{@http_if_none_match}\n<br/>\n"
    res += "http_content_type => #{@http_content_type}\n<br/>\n"
    res += "http_path_info => #{@http_path_info}\n<br/>\n"
    res += "http_request_uri => #{@http_request_uri}\n<br/>\n"
    res += "http_query_string => #{@http_query_string}\n<br/>\n"
    res += "http_post_content => #{@http_post_content}\n<br/>\n"
    res += "http_headers => #{@http_headers}\n<br/>\n"
    return res
  end
end

EM.run {
  EM.start_server '0.0.0.0', 8080, Server
}
