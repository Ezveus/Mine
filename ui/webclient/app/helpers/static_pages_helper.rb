module StaticPagesHelper
  def title
    base_title = "Mine Is Not Emacs : Embedded Client"
    return "#{base_title} - #{@title}" if @title
    base_title
  end
end
