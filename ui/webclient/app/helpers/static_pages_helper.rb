module StaticPagesHelper
  def title
    base_title = "Mine Is Not Emacs : Embedded Client"
    if @title
      return "#{base_title} - #{@title}"
    end
    base_title
  end
end
