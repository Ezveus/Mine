load 'MineCommand.rb'

module Mine
  class Binding
    include Mine::Command

    attr_accessor :key, :call, :mod

    def initialize(key, call, mod = Mine::Command)
      @key = key
      @mod = mod
      @call = @mod.method(call.to_sym)
    end
  end
end
