class ChartData

  def initialize(chart_type, stack_the_bars)
    @chart_type = chart_type
    @stack_the_bars = stack_the_bars
    @index = []
    @x = []
    @y = []
    @series_names = []
  end

  def add_data_point(series_name, x, y)
    @index.push(@index.length)
    @x.push(x)
    @y.push(y)
    @series_names.push(series_name)
  end

  def fill_blank_values(x_values, default_series_name, default_value)
    x_values.each do |x|
      if not @x.include?(x)
        @x.push(x)
        @y.push(default_value)
        @series_names.push(default_series_name)
      end
    end
  end

  def to_builder
    Jbuilder.new do |json|
      json.chart_type @chart_type
      json.stack_the_bars @stack_the_bars
      json.index @index
      json.x @x
      json.y @y
      json.series_names @series_names  # include even if null- will appear as empty string in the json
    end
  end
end