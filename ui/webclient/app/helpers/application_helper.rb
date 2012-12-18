module ApplicationHelper
  def is_active? active
    'active' if active == @active
  end
end
