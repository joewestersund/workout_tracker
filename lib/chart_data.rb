class ChartData

  def initialize(chart_type, stack_the_bars, data_type_name, units)
    @chart_type = chart_type
    @stack_the_bars = stack_the_bars
    @data_type_name = data_type_name
    @units = units
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
        @index.push(@index.length)
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
      json.data_type_name @data_type_name
      json.units @units
      json.chart_data @index.each do |i|
        json.x_value @x[i]
        json.y_value @y[i]
        json.series_name @series_names[i]
      end
    end
  end
end