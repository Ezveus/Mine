module MineClient
  class Binding
    include Command

    attr_accessor :key, :call, :mod

    def initialize key, call, mod = Command
      @key = key
      @mod = mod
      @call = @mod.method call.to_sym
    end
  end
end
