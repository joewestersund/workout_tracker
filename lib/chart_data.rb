class ChartData

  def initialize()
    @index = []
    @x = []
    @y = []
    @series_names = []
  end

  def add_data_point(series_name, x, y)
    @index.push(@index.length)
    @x.push(x)
    @y.push(y)
    @series_names << series_name
  end

end