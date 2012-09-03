class Cursor
  attr_reader :line
  attr_reader :column
  attr_reader :owner

  @file = ""
  @offset

  def initialize owner, file, line = 0
    @line = line
    @column = 0
    @owner = owner
    @file = file
    @offset = 0
    i = 0
    while i < @line && @file[@offset] != '\0'
      @offset += 1
      if @file[@offset] == '\n'
        i += 1
      end
    end
    @offset += 1 unless @offset == 0
  end

  def move_up
    if @line > 0
      @offset -= 2
      @offset -= 1 until @file[@offset] == '\n' || @offset == 0
      @offset += 1
      @line -= 1
    else
      @column = 0
    end
    [@line, @column, @offset]
  end

  def move_right
    print @file[@offset + @column]
    if @file[@offset + @column] == "\n"
      @offset += @column + 1
      @line += 1
      @column = 0
    else
      @column += 1 if @offset + @column < @file.size
    end
    [@line, @column, @offset]
  end

  def move_down
    last_line = @file[@offset, @file.size - @offset]
    if nb = (last_line =~ /\n/)
      @line += 1
      @offset += nb + 1
    else
      @column = last_line.size - 1
    end
    [@line, @column, @offset]
  end

  def move_left
    if @line > 0
      if @column > 0
        @column -= 1
      else
        @line -= 1
        @offset -= 2
        columns = @offset
        @offset -= 1 while @file[@offset] != "\n" && @offset != 0
        @offset += 1
        @column = columns - @offset + 1
      end
    end
    [@line, @column, @offset]
  end

end
