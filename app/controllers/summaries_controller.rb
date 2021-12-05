require 'ostruct'
require 'summary_table'
require 'chart_data'

class ColumnNameAndID
  def column_id
    @column_id
  end

  def column_id=(column_id)
    @column_id = column_id
  end

  def column_name
    @column_name
  end

  def column_name=(column_name)
    @column_name = column_name
  end
end

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

class SummariesController < ApplicationController
  before_action :signed_in_user
  before_action :get_field_types
  before_action :set_workout_type_route_data_type
  #before_action :get_params_for_link_url
  #before_action :test_if_filtered

  SUMMARY_TYPE_TIME_SERIES = "time series"
  SUMMARY_TYPE_X_VS_Y = "x vs y"

  def time_series
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    @summary_options_json = get_summary_options_json(@workout_type)

    valid = @data_type.present?
    include_blank_rows = true

    respond_to do |format|
      format.html {
        if valid && @show_table
          @table = get_time_series_data(@data_type, @summary_function, @averaging_time, @show_table, include_blank_rows)
        end
      }
      format.json {
        if valid
          render :json => get_time_series_data(@data_type, @summary_function, @averaging_time, @show_table, include_blank_rows)
        else
          render json: "data type not recognized or not for the same workout type", status: :unprocessable_entity
        end
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

    def order_by
      "year desc, month desc, week desc, day desc" #always this, no matter the averaging time.
    end

    def get_time_series_data(data_type, summary_function, averaging_time, table_format, include_blank_rows)
      averaging_time_fields = get_averaging_time_fields(averaging_time)

      conditions = get_conditions
      group_by_str = group_by(averaging_time)

      column_names = current_user.workouts.joins(workout_routes: [:data_points, :route])
          .where("data_points.data_type_id = #{data_type.id}")
          .where(conditions)
          .select("routes.id as column_id, routes.name as column_name")
          .group("routes.id, routes.name, routes.order_in_list")
          .order(:order_in_list)
      data = current_user.workouts.joins(workout_routes: :data_points)
          .where("data_points.data_type_id = #{data_type.id}")
          .where(conditions)

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
      data_by_route = data_by_route.group("route_id, #{group_by_str}").order(order_by)
      data_all_routes = data_all_routes.group(group_by_str).order(order_by)

      if include_blank_rows
        row_names = []

        first_row = data_all_routes.first
        last_row = data_all_routes.last

        if first_row.present?
          # note: data_all_routes is ordered descending with time. So first row = last date.
          last_date = get_start_of_period_date(first_row.year, first_row.month, first_row.week, first_row.day)
          first_date = get_start_of_period_date(last_row.year, last_row.month, last_row.week, last_row.day)

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
            .where("data_points.data_type_id = #{data_type.id}")
            .where(conditions)
            .select("#{averaging_time_fields}")
            .group(group_by_str).order(order_by)
      end

      if table_format
        return create_summary_table(row_names, column_names, data_by_route, data_all_routes, data_type)
      else
        return create_chart_data(column_names,data)
      end

    end

    def create_chart_data(column_names,data,summary_type)
      cd = ChartData.new
      columns_hash = {}

      index=0
      column_names.each do |c|
        cd.add_series(c.column_name)
        columns_hash[c.column_id] = index
        index += 1
      end

      if summary_type == :by_transaction_direction
        #this type uses custom sql, so the data is in a different structure.
        data.each do |d|
          year = d[0].to_i
          month = d[1] ? d[1].to_i : 1  #d[1] may be zero if we're averaging yearly
          day = d[2] ? d[2].to_i : 1 #d[2] may be zero if we're averaging yearly or monthly
          x = Date.new(year,month,day)  #d[0] = year, d[1] = month, d[2] = day
          cd.add_data_point(0,x,d[3].to_f) #income
          cd.add_data_point(1,x,d[4].to_f) #spending
          cd.add_data_point(2,x,d[5].to_f) #savings
        end
      else
        data.each do |d|
          col_id = nil_to_zero(d.column_id)
          column = columns_hash[col_id]
          x = Date.new(d.year,d.month || 1, d.day || 1)
          cd.add_data_point(column,x,d.amount_sum.to_f)
        end
      end

      cd.remove_unused_series

      return cd

    end

    def create_summary_table(row_names, column_names, data, data_all_routes, data_type)
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
        href = workouts_path #+ get_query_string(r.year, r.month, r.day, summary_type, nil)
        st.set_header_href(:row, index, href)
        d = get_start_of_period_date(r.year, r.month, r.week, r.day)
        #if r.week
        #  d = Date.commercial(r.year, r.week) # first day of that week
        #else
        #  d = Date.new(r.year,r.month || 1,1)  # first day of month or year
        #end
        st.set_row_numeric_value(index,d)
        index += 1
      end

      index=0
      column_names.each do |c|
        columns_hash[c.column_id] = index
        st.set_header_text(:column,index, c.column_name)
        href = workouts_path + get_query_string(nil, nil, nil, nil, data_type.workout_type_id, c.column_id)
        st.set_header_href(:column, index, href)
        index += 1
      end

      # add the column for all routes
      column_name = 'all'
      columns_hash['all'] = index
      st.set_header_text(:column,index, column_name)
      href = workouts_path + get_query_string(nil, nil, nil, nil, data_type.workout_type_id, nil)
      st.set_header_href(:column, index, href)

      data.each do |d|
        row = rows_hash[get_row_name(d.year, d.month, d.week, d.day)]
        col_id = nil_to_zero(d.column_id)
        column = columns_hash[col_id]
        val = data_type.convert_from_number(d.result)
        st.set_text(row, column, val, val)
        href = workouts_path #+ get_query_string(d.start_date, d.end_date, d.year, d.month, d.workout_type.id, d.route_id)
        st.set_href(row,column,href)
      end

      data_all_routes.each do |d|
        row = rows_hash[get_row_name(d.year, d.month, d.week, d.day)]
        col_id = nil_to_zero(d.column_id)
        column = columns_hash[col_id]
        val = data_type.convert_from_number(d.result)
        st.set_text(row, column, val, val)
        href = workouts_path #+ get_query_string(d.start_date, d.end_date, d.year, d.month, d.workout_type.id, d.route_id)
        st.set_href(row,column,href)
      end

      return st
    end

    def get_query_string(start_date, end_date, year, month, workout_type_id, route_id)
      qs = []
      qs << "start_date=#{start_date}" if start_date.present?
      qs << "end_date=#{end_date}" if end_date.present?
      qs << "year=#{year}" if year.present?
      qs << "month=#{month}" if month.present?
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
        "#{month}/#{day}/#{year}"
      else
        "#{(month.to_s + ' ') if month.present?}#{year}"
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

    def get_field_types
      @field_types = DataType.field_types
    end

    def set_workout_type_route_data_type
      if params[:data_type_id].present?
        @data_type = current_user.data_types.find(params[:data_type_id])
        @workout_type = @data_type.workout_type
      elsif params[:workout_type_id].present?
        @workout_type = current_user.workout_types.find(params[:workout_type_id])
        @data_type = @workout_type.data_types.order(:order_in_list).first
      else
        current_user.workout_types.order(:order_in_list).each do |wt|
          if wt.data_types.count > 0
            @data_type = wt.data_types.order(:order_in_list).first
            @workout_type = wt
            break
          end
        end
      end

      @workout_types = current_user.workout_types.order(:order_in_list)
      @routes = @workout_type.routes.order(:order_in_list)
      fth = DataType.field_types_hash
      @data_types = @workout_type.data_types.where(field_type: [fth[:numeric], fth[:hours_minutes], fth[:minutes_seconds]]).order(:order_in_list)
      @averaging_times = %w[ day week month year]

      if params[:route_id].present?
        @route = @workout_type.routes.find(params[:route_id])
      else
        @route = @routes.first
      end

      @summary_function = param_or_first(:summary_function, nil, @data_type.summary_function_options)

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
end
