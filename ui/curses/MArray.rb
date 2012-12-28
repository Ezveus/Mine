class Array
  # This function returns the element which corresponds to the given hash.
  # Returns nil if fails.
  def find hash
    self.each do |elem|
      equal = true
      hash.each do |key, val|
        begin
          equal &= elem.method(key).call == val
        rescue => exception
          return nil
        end
      end
      return elem if equal
    end
    return nil
  end

  # This function returns an Array of the elements
  # which correspond to the given hash.
  # Returns nil if fails.
  def find_all hash
    res = []
    self.each do |elem|
      equal = true
      hash.each do |key, val|
        begin
          equal &= elem.method(key).call == val
        rescue => exception
          return nil
        end
      end
      res << elem if equal
    end
    res
  end

  # This function returns the index of the element
  # which corresponds to the given hash.
  # Returns nil if fails.
  def find_index hash
    self.each_index do |index|
      equal = true
      hash.each do |key, val|
        begin
          equal &= self[index].method(key).call == val
        rescue => exception
          return nil
        end
      end
      return index if equal
    end
    return nil
  end

  # This function returns an Array of the index of the elements
  # which correspond to the given hash.
  # Returns nil if fails.
  def find_index_all hash
    res = []
    self.each_index do |index|
      equal = true
      hash.each do |key, val|
        begin
          equal &= self[index].method(key).call == val
        rescue => exception
          return nil
        end
      end
      res << index if equal
    end
    res
  end
end
