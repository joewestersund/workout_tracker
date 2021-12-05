module TableHelper

  def display_bool(bool)
    bool ? "Y" : "N"
  end

  def display_date(date)
    if date.present?
      date.strftime('%m/%-d/%Y')
    end
  end

  def display_date_with_day_of_week(date)
    if date.present?
      date.strftime('%A %m/%-d/%Y')
    end
  end

end