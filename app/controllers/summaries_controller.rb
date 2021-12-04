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

    respond_to do |format|
      format.html {
        if valid && @show_table
          @table = get_time_series_data(@data_type, @summary_function, @show_table)
        end
      }
      format.json {
        if valid
          render :json => get_time_series_data(@data_type, @summary_function, @show_table)
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

    def get_averaging_time
      at = params[:averaging_time]
      if at == "year"
        at_str = "year, null as month, null as week"
      elsif at == "month"
        at = "month"
        at_str = "year, month, null as week"
      else #default to week
        at_str = "year, month, week"
      end
      @averaging_time = at
      return at_str
    end

    def group_by
      at = params[:averaging_time]
      if at == "year"
        "year"
      elsif at == "month"
        "year, month"
      else #default to week
        "year, month, week"
      end
    end

    def order_by
      "year desc, month desc, week desc" #always this, no matter the averaging time.
    end

    def get_time_series_data(data_type, aggregate_function, table_format)
      averaging_time_string = get_averaging_time
      conditions = get_conditions
      column_names = data_type.workout_type.routes.where(conditions).select("id as column_id, name as column_name").order(:order_in_list).all
      row_names = current_user.workouts.joins(workout_routes: :data_points)
          .where("data_points.data_type_id = #{data_type.id}")
          .where(conditions)
          .select("#{averaging_time_string}")
          .group(group_by).order(order_by)
      data = current_user.workouts.joins(workout_routes: :data_points)
          .where("data_points.data_type_id = #{data_type.id}")
          .where(conditions)
          .select("#{averaging_time_string}, #{aggregate_function}(decimal_value) as result, route_id as column_id")
          .group("route_id, #{group_by}").order(order_by)

      if table_format
        return create_summary_table(row_names,column_names,data)
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

    def create_summary_table(row_names, column_names, data)
      row_count = row_names.each.count
      column_count = column_names.each.count
      st = SummaryTable.new(row_count, column_count)
      rows_hash = {}
      columns_hash = {}

      index=0
      row_names.each do |r|
        row_name = get_row_name(r.year, r.month, r.week)
        rows_hash[row_name] = index
        st.set_header_text(:row, index, row_name)
        href = workouts_path #+ get_query_string(r.year, r.month, r.day, summary_type, nil)
        st.set_header_href(:row, index, href)
        if r.week
          d = Date.commercial(r.year, r.week) # first day of that week
        else
          d = Date.new(r.year,r.month || 1,1)  # first day of month or year
        end
        st.set_row_numeric_value(index,d)
        index += 1
      end

      index=0
      column_names.each do |c|
        columns_hash[c.column_id] = index
        st.set_header_text(:column,index, c.column_name)
        href = workouts_path #+ get_query_string(nil, nil, nil, summary_type, c.column_id)
        st.set_header_href(:column, index, href)
        index += 1
      end

      data.each do |d|
        row = rows_hash[get_row_name(d.year, d.month, d.week)]
        col_id = nil_to_zero(d.column_id)
        column = columns_hash[col_id]
        st.set_text(row, column, d.result, d.result.to_f)
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

    def get_row_name(year, month, week)
      "#{(month.to_s + ' ') if month.present?}#{('week ' + week.to_s + ' ') if week.present?}#{year}"
    end

    def search_params
      params.permit(:year, :month, :workout_type_id)
    end

    def get_conditions

      search_terms = Workout.new(search_params)

      conditions = {}
      conditions_string = []

      conditions[:start_date] = params[:start_date] if params[:start_date].present?
      conditions_string << "workout_date >= :start_date" if params[:start_date].present?

      conditions[:end_date] = params[:end_date] if params[:end_date].present?
      conditions_string << "workout_date <= :end_date" if params[:end_date].present?

      conditions[:year] = search_terms.year if search_terms.year.present?
      conditions_string << "year = :year" if search_terms.year.present?

      conditions[:month] = search_terms.month if search_terms.month.present?
      conditions_string << "month = :month" if search_terms.month.present?

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
      @data_types = @workout_type.data_types.order(:order_in_list)

      if params[:route_id].present?
        @route = @workout_type.routes.find(params[:route_id])
      else
        @route = @routes.first
      end

      if params[:summary_function].present?
        @summary_function = params[:summary_function]
      else
        @summary_function = @data_type.summary_function_options[0] # default to first option in this list
      end

    end

end
