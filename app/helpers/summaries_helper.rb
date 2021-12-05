module SummariesHelper
  def mark_current_tab(current_value,value_this_tab)
    if current_value == value_this_tab
      "current"
    end
  end
end
