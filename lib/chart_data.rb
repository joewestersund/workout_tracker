class ChartData

  def initialize(chart_type, stack_the_bars, x_label, y_label)
    @chart_type = chart_type
    @stack_the_bars = stack_the_bars
    @x_label = x_label
    @y_label = y_label
    @index = []
    @series_names = []
    @x = []
    @y = []
    @labels = []
  end

  def add_data_point(series_name, x, y, label)
    @index.push(@index.length)
    @series_names.push(series_name)
    @x.push(x)
    @y.push(y)
    @labels.push(label)
  end

  def fill_blank_values(x_values, default_series_name, default_value)
    x_values.each do |x|
      if not @x.include?(x)
        @index.push(@index.length)
        @series_names.push(default_series_name)
        @x.push(x)
        @y.push(default_value)
        @labels.push("")
      end
    end
  end

  def to_builder
    Jbuilder.new do |json|
      json.chart_type @chart_type
      json.stack_the_bars @stack_the_bars
      json.x_label @x_label
      json.y_label @y_label
      json.chart_data @index.each do |i|
        json.series_name @series_names[i]
        json.x_value @x[i]
        json.y_value @y[i]
        json.label @labels[i]
      end
    end
  end
end