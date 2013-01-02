#!/usr/bin/env ruby

module Constant
  RequestSize ||= 4096

  Success ||= "OK"
  Fail ||= "KO"

  Ok ||= 0
  UnvalidRequest ||= 1
  UnknownRequest ||= 2
  JSONParserError ||= 3
  UnknownUser ||= 4
  BadRegistration ||= 5
  ForbiddenAction ||= 6
  UnknownBuffer ||= 7
end
