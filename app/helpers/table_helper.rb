module TableHelper

  def display_bool(bool)
    bool ? "Y" : "N"
  end

  def display_date(date)
    if date.present?
      date.strftime('%m/%e/%Y')
    end
  end

end