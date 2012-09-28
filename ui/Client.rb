#!/usr/bin/env ruby

require 'eventmachine'
require 'em-http'

EM.run do
request_options = {
    :keepalive => true,
    :path => '/mine/protocol/request',
    :body =>  {"AUTHENTICATE" => '{"name":"toto","pass":"pl0"}'}
  }

  http = EventMachine::HttpRequest.new('http://localhost:8080').post request_options
  http.callback {puts http.response}
end
