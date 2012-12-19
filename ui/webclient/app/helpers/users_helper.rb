module UsersHelper
  def conjugBe person, count
    res = case person
          when :first then conjugBeFirst count
          when :second then conjugBeSecond
          when :third then conjugBeThird count
          else "are"
          end
  end

  private
  def conjugBeFirst count
    return "am" if count <= 1
    "are"
  end

  def conjugBeSecond
    "are"
  end

  def conjugBeThird count
    return "is" if count <= 1
    "are"
  end
end
