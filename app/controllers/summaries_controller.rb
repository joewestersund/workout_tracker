require 'ostruct'
require 'summary_table'
require 'chart_data'
require 'column_name_and_id'
require 'date_fields'


class SummariesController < ApplicationController
  before_action :signed_in_user
  before_action :get_params_for_link_url
  #before_action :test_if_filtered

  SUMMARY_TYPE_TIME_SERIES = "time series"
  SUMMARY_TYPE_X_VS_Y = "x vs y"

  def time_series
    set_workout_type_route_data_type
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    @summary_options_json = get_summary_options_json(@workout_type)

    if @data_type.present? && @route.present?
      @description = "#{@summary_function} of #{@data_type.name} for '#{@route.name}', by #{@averaging_time}"
    elsif @data_type.present?
      @description = "#{@summary_function} of #{@data_type.name}, by #{@averaging_time}"
    elsif @route.present?
      @description = "Number of times you completed '#{@route.name}', by #{@averaging_time}"
    else
      @description = "Number of times you completed each route, by #{@averaging_time}"
    end
    include_blank_rows = true

    respond_to do |format|
      format.html {
        if @show_table
          @table = get_time_series_data(@workout_type, @route, @data_type, @summary_function, @averaging_time, @show_table, include_blank_rows)
        end
      }
      format.json {
        render :json => get_time_series_data(@workout_type, @route, @data_type, @summary_function, @averaging_time, @show_table, include_blank_rows)
      }
    end

  end

  def x_vs_y
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    at = get_averaging_time
    @workout_filter_json = get_workout_filter_json()
    @dt1 = current_user.data_types.find(params[:data_type_id_1])
    @dt2 = current_user.data_types.find(params[:data_type_id_2])

    valid = @dt1.present? && @dt2.present? && @dt1.workout_type == @dt2.workout_type

    respond_to do |format|
      format.html {
        if valid && @show_table
          @table = get_x_vs_y_data(@dt1, @dt2, at,@show_table)
        end
      }
      format.json {
        if valid
          render :json => get_x_vs_y_data(@dt1, @dt2, at,@show_table)
        else
          render json: "data types not recognized or not for the same workout type", status: :unprocessable_entity
        end
      }
    end

  end

  private
    def get_summary_options_json(workout_type)
      @summary_options_json = Jbuilder.new do |json|
        json.data_types workout_type.data_types.where(active: true).map { |dt| dt.to_builder.attributes! }
      end.target!.html_safe
    end

    def get_params(summary_type)
      if summary_type == SUMMARY_TYPE_TIME_SERIES
        @params_for_link_url = params.permit(:start_date, :end_date, :year, :month, :week, :route_id, :data_type_id, :display, :averaging_time)
      else
        @params_for_link_url = params.permit(:start_date, :end_date, :year, :month, :week, :route_id, :data_type_id, :display)
      end
    end

    def test_if_filtered(summary_type)
      @filtered = false
      filter_params = %w[start_date, end_date, year, month, week, route_id]

      filter_params.each do |p|
        param_value = params.fetch(p,nil)
        if !param_value.nil? and !param_value.empty? then
          @filtered = true
          break
        end
      end
    end

    def show_table
      return params[:display] != "chart"
    end

    def get_averaging_time_fields(averaging_time)
      if averaging_time == "year"
        at_str = "year, null as month, null as week, null as day"
      elsif averaging_time == "month"
        at_str = "year, month, null as week, null as day"
      elsif averaging_time == "week"
        at_str = "year, null as month, week, null as day"
      else #default to day
        at_str = "year, month, null as week, day"
      end
      return at_str
    end

    def group_by(averaging_time)
      if averaging_time == "year"
        "year"
      elsif averaging_time == "month"
        "year, month"
      elsif averaging_time == "week"
        "year, week"
      else #default to day
        "year, month, day"
      end
    end

    def order_by_desc
      "year desc, month desc, week desc, day desc" #always this, no matter the averaging time.
    end

    def order_by_asc
      "year, month, week, day"
    end

    def get_time_series_data(workout_type, route, data_type, summary_function, averaging_time, table_format, include_blank_rows)
      averaging_time_fields = get_averaging_time_fields(averaging_time)

      conditions = get_conditions
      group_by_str = group_by(averaging_time)

      if data_type.present?
      column_names = current_user.workouts.joins(workout_routes: [:data_points, :route])
          .where("data_points.data_type_id = #{data_type.id}")
      else
        column_names = current_user.workouts.joins(workout_routes: :route)
          .where("workouts.workout_type_id = #{workout_type.id}")
      end
      column_names = column_names.where(conditions)
          .select("routes.id as column_id, routes.name as column_name")
          .group("routes.id, routes.name, routes.order_in_list")
          .order(:order_in_list)

      if data_type.present?
        data = current_user.workouts.joins(workout_routes: :data_points)
            .where("data_points.data_type_id = #{data_type.id}")
      else
        data = current_user.workouts.joins(:workout_routes)
            .where("workouts.workout_type_id = #{workout_type.id}")
      end
      data = data.where(conditions)

      if summary_function == "average"
        data_by_route = data.select("#{averaging_time_fields}, sum(decimal_value * repetitions) / sum(repetitions) as result, route_id as column_id")
        data_all_routes = data.select("#{averaging_time_fields}, sum(decimal_value * repetitions) / sum(repetitions) as result, 'all' as column_id")
      elsif summary_function == "sum"
        data_by_route = data.select("#{averaging_time_fields}, sum(decimal_value * repetitions) as result, route_id as column_id")
        data_all_routes = data.select("#{averaging_time_fields}, sum(decimal_value * repetitions) as result, 'all' as column_id")
      elsif summary_function == "min" || summary_function == "max"
        data_by_route = data.select("#{averaging_time_fields}, #{summary_function}(decimal_value) as result, route_id as column_id")
        data_all_routes = data.select("#{averaging_time_fields}, #{summary_function}(decimal_value) as result, 'all' as column_id")
      elsif summary_function == "count"
        data_by_route = data.select("#{averaging_time_fields}, sum(repetitions) as result, route_id as column_id")
        data_all_routes = data.select("#{averaging_time_fields}, sum(repetitions) as result, 'all' as column_id")
      else
        raise "summary function #{summary_function} was not recognized"
      end

      order_by = table_format ? order_by_desc : order_by_asc
      data_by_route = data_by_route.group("route_id, #{group_by_str}").order(order_by)
      data_all_routes = data_all_routes.group(group_by_str).order(order_by)

      if include_blank_rows
        row_names = []

        first_row = data_all_routes.first
        last_row = data_all_routes.last

        if first_row.present?
          # note: data_all_routes is ordered ascending or descending with time, depending on table vs chart view.
          d1 = get_start_of_period_date(first_row.year, first_row.month, first_row.week, first_row.day)
          d2 = get_start_of_period_date(last_row.year, last_row.month, last_row.week, last_row.day)

          if d1 < d2
            first_date = d1
            last_date = d2
          else
            first_date = d2
            last_date = d1
          end

          d = last_date

          if averaging_time == "day"
            interval = 1.day
          elsif averaging_time == "week"
            interval = 1.week
          elsif averaging_time == "month"
            interval = 1.month
          elsif averaging_time == "year"
            interval = 1.year
          else
            raise "averaging time #{averaging_time} not handled"
          end

          while d >= first_date
            df = DateFields.new(d.year, d.month, d.cweek, d.day, averaging_time)
            row_names << df
            d -= interval
          end
        end
      else
        # only include rows for which there will be data
        row_names = current_user.workouts.joins(workout_routes: :data_points)
        row_names = row_names.where("data_points.data_type_id = #{data_type.id}") if data_type.present?
        row_names = row_names.where(conditions)
            .select("#{averaging_time_fields}")
            .group(group_by_str).order(order_by)
      end

      if table_format
        return create_summary_table(workout_type, data_type, row_names, column_names, data_by_route, data_all_routes)
      else
        stack_bars = (summary_function.blank? || summary_function == "sum")
        return create_chart_data("bar", stack_bars, data_type, row_names, column_names, data_by_route)
      end

    end

    def create_chart_data(chart_type, stack_bars, data_type, row_names, column_names, data_by_route)

      if data_type.present?
        cd = ChartData.new(chart_type, stack_bars, data_type.name, data_type.units)
      else
        cd = ChartData.new(chart_type, stack_bars, "Times completed", nil)
      end

      columns_hash = {}

      column_names.each do |c|
        columns_hash[c.column_id] = c.column_name
      end

      data_by_route.each do |d|
        col_id = nil_to_zero(d.column_id)
        column_name = columns_hash[col_id]
        x = get_start_of_period_date(d.year, d.month, d.week, d.day)
        if data_type.present?
          y_value = data_type.convert_to_number_for_chart(d.result.to_f)
        else
          y_value = d.result.to_f
        end
        cd.add_data_point(column_name, x, y_value)
      end

      x_values = []
      row_names.each do |r|
        x_values << get_start_of_period_date(r.year, r.month, r.week, r.day)
      end

      if chart_type == "bar"
        if column_names.length > 0
          cd.fill_blank_values(x_values, column_names.first.column_name, nil)
        end
      end

      return cd.to_builder.target!.html_safe

    end

    def create_summary_table(workout_type, data_type, row_names, column_names, data, data_all_routes)
      row_count = row_names.each.count
      column_count = column_names.each.count + 1   # add one, for the 'all routes' column

      st = SummaryTable.new(row_count, column_count)
      rows_hash = {}
      columns_hash = {}

      index=0
      row_names.each do |r|
        row_name = get_row_name(r.year, r.month, r.week, r.day)
        rows_hash[row_name] = index
        st.set_header_text(:row, index, row_name)
        href = workouts_path + get_query_string(r.year, r.month, r.week, r.day, workout_type.id, nil)
        st.set_header_href(:row, index, href)
        d = get_start_of_period_date(r.year, r.month, r.week, r.day)
        st.set_row_numeric_value(index,d)
        index += 1
      end

      index=0
      column_names.each do |c|
        columns_hash[c.column_id] = index
        st.set_header_text(:column,index, c.column_name)
        href = workouts_path + get_query_string(nil, nil, nil, nil, workout_type.id, c.column_id)
        st.set_header_href(:column, index, href)
        index += 1
      end

      # add the column for all routes
      column_name = 'all'
      columns_hash['all'] = index
      st.set_header_text(:column,index, column_name)
      href = workouts_path + get_query_string(nil, nil, nil, nil, workout_type.id, nil)
      st.set_header_href(:column, index, href)

      data.each do |d|
        row = rows_hash[get_row_name(d.year, d.month, d.week, d.day)]
        col_id = nil_to_zero(d.column_id)
        column = columns_hash[col_id]
        val = data_type.present? ? data_type.convert_from_number(d.result) : d.result
        st.set_text(row, column, val, val)
        href = workouts_path + get_query_string(d.year, d.month, d.week, d.day, workout_type.id, d.column_id)
        st.set_href(row,column,href)
      end

      data_all_routes.each do |d|
        row = rows_hash[get_row_name(d.year, d.month, d.week, d.day)]
        col_id = nil_to_zero(d.column_id)
        column = columns_hash[col_id]
        val = data_type.present? ? data_type.convert_from_number(d.result) : d.result
        st.set_text(row, column, val, val)
        href = workouts_path + get_query_string(d.year, d.month, d.week, d.day, workout_type.id, nil)
        st.set_href(row,column,href)
      end

      return st
    end

    def get_query_string(year, month, week, day, workout_type_id, route_id)
      qs = []
      if week.present?
        d = get_start_of_period_date(year, month, week, day)
        d2 = d + 6.days
        qs << "start_date=#{d}"
        qs << "end_date=#{d2}"
      else
        qs << "year=#{year}" if year.present?
        qs << "month=#{month}" if month.present?
        qs << "day=#{day}" if day.present?
      end
      qs << "workout_type_id=#{workout_type_id}" if workout_type_id.present?
      qs << "route_id=#{route_id}" if route_id.present?
      if qs.length > 0
        "?" + qs.join("&")
      else
        "" #nil
      end
    end

    def get_row_name(year, month, week, day)
      if week.present?
        d = Date.commercial(year, week)
        "#{d.month}/#{d.day}/#{d.year}"
      elsif day.present?
        d = Date.new(year,month,day)
        d.strftime('%A %m/%-d/%Y')
      else
        "#{(month.to_s + '/') if month.present?}#{year}"
      end
    end

    def get_conditions
      conditions = {}
      conditions_string = []

      conditions[:start_date] = params[:start_date] if params[:start_date].present?
      conditions_string << "workout_date >= :start_date" if params[:start_date].present?

      conditions[:end_date] = params[:end_date] if params[:end_date].present?
      conditions_string << "workout_date <= :end_date" if params[:end_date].present?

      conditions[:year] = params[:year] if params[:year].present?
      conditions_string << "year = :year" if params[:year].present?

      conditions[:month] = params[:month] if params[:month].present?
      conditions_string << "month = :month" if params[:month].present?

      conditions[:route_id] = params[:route_id] if params[:route_id].present?
      conditions_string << "workout_routes.route_id = :route_id" if params[:route_id].present?

      return [conditions_string.join(" AND "), conditions]
    end

    def set_workout_type_route_data_type
      @workout_types = current_user.workout_types.order(:order_in_list)

      if params[:workout_type_id].present?
        @workout_type = current_user.workout_types.find(params[:workout_type_id])
      else
        @workout_type = @workout_types.first
      end

      if params[:data_type_id].present?
        @data_type = @workout_type.data_types.find(params[:data_type_id])
        @summary_function = param_or_first(:summary_function, nil, @data_type.summary_function_options)
      else
        @summary_function = "count"  # we can only return a count, not a sum, average etc, if this is not specific to a data_type
      end

      @routes = @workout_type.routes.order(:order_in_list)
      if params[:route_id].present?
        @route = @workout_type.routes.find(params[:route_id])
      end

      fth = DataType.field_types_hash
      @data_types = @workout_type.data_types.where(field_type: [fth[:numeric], fth[:hours_minutes], fth[:minutes_seconds]]).order(:order_in_list)
      @averaging_times = %w[ day week month year]

      @averaging_time =  param_or_first(:by, nil, @averaging_times)
    end

    def param_or_first(param_name, find_in, array)
      if params[param_name].present?
        if find_in.present?
          find_in.find(params[param_name])
        else
          params[param_name]
        end
      else
        array.first
      end
    end

    def get_start_of_period_date(year, month, week, day)
      if week
        d = Date.commercial(year, week) # first day of that week
      else
        d = Date.new(year, month || 1, day || 1)  # first day of year if no month or day. First day of month if no day.
      end
    end

    def get_params_for_link_url
      @params_for_link_url = params.permit(:workout_type_id, :route_id, :data_type_id, :summary_function, :by)
    end
end
