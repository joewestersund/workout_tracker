class ChartData

  def initialize()
    @series_names = Array.new
    @data = Array.new
  end

  def add_series(series_name)
    @series_names.push(series_name)
    @data.push Array.new
  end

  def add_data_point(series_index,x,y)
    #points for each series must be added in order
    @data[series_index].push [x,y]
    @min_x = min(@min_x,x)
    @max_x = max(@max_x,x)
    @min_y = min(@min_y,y)
    @max_y = max(@max_y,y)
  end

  def remove_unused_series
    original_length = @data.length
    @series_names.each_with_index do |s,i|
      index = original_length - i - 1 #iterate backwards so deleting array items doesn't cause problems
      if @data[index].length == 0
        @data.slice!(index)
        @series_names.slice!(index)
      end
    end
  end

private

  def max(current,new)
    current.nil? || new > current ? new : current
  end

  def min(current,new)
    current.nil? || new < current ? new : current
  end

end