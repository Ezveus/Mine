#!/usr/bin/env ruby

module Mine
  module Constant
    RequestSize ||= 4096

    Success ||= "OK"
    Fail ||= "KO"

    Ok ||= 0
    MissingIDError ||= 1
    UnvalidRequest ||= 2
    UnknownRequest ||= 3
    JSONParserError ||= 4
    UnknownUser ||= 5
    BadRegistration ||= 6
    ForbiddenAction ||= 7
    UnknownBuffer ||= 8
    AlreadyLogged ||= 9
    UnknownCommand ||= 10
    PathError ||= 11
    AlreadyCreated ||= 12
    UnknownFile ||= 13
    DirectoryNotEmpty ||= 14
  end
end
