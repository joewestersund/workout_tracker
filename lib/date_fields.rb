class DateFields
  def initialize(year, month, week, day, averaging_time)
    @year = year
    @month = month if averaging_time == "day" || averaging_time == "month"
    @week = week if averaging_time == "week"
    @day = day if averaging_time == "day"
  end

  def year
    @year
  end

  def month
    @month
  end

  def week
    @week
  end

  def day
    @day
  end
end