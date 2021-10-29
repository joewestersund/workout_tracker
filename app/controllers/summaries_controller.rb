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
  before_action :get_params_for_link_url
  before_action :test_if_filtered

  def by_account
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    at = get_averaging_time
    @user_accounts = current_user.accounts.order('order_in_list').all

    respond_to do |format|
      format.html {
        if @show_table
          @table = get_by_account_data(at,@show_table)
        end
      }
      format.json {
        render :json => get_by_account_data(at,@show_table)
      }
    end

  end

  def by_category
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    at = get_averaging_time
    @user_transaction_categories = current_user.transaction_categories.order('order_in_list').all

    respond_to do |format|
      format.html {
        if @show_table
          @table = get_by_category_data(at,@show_table)
        end
      }
      format.json {
        render :json => get_by_category_data(at,@show_table)
      }
    end

  end

  def by_transaction_direction
    @show_table = show_table
    @display = (@show_table ? "table" : "chart")
    at = get_averaging_time

    respond_to do |format|
      format.html {
        if @show_table
          @table = get_transaction_direction_data(at,@show_table)
        end
      }
      format.json {
        render :json => get_transaction_direction_data(at,@show_table)
      }
    end
  end

  private
    def get_params_for_link_url
      #params_to_exclude = ["averaging_time", "display"]
      #filtered_params = params.reject{ |key, value| params_to_exclude.include?(key) }

      #@params_for_link_url = "&" + URI.encode(filtered_params.to_hash.map{|k,v| "#{k}=#{v}"}.join("&"))

      @params_for_link_url = params.permit(:display, :averaging_time, :year, :month, :day, :transaction_category_id, :account_id)
    end

    def test_if_filtered
      @filtered = false
      filter_params = ["year", "month", "day"]
      filter_params.push("account_id") if params["action"] == "by_account"
      filter_params.push("transaction_category_id") if params["action"] == "by_category"

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
        at_str = "year, null as month, null as day"
      elsif at == "day"
        at_str = "year, month, day"
      else  #default to monthly view
        at = "month"
        at_str = "year, month, null as day"
      end
      @averaging_time = at
      return at_str
    end

    def group_by
      at = params[:averaging_time]
      if at == "year"
        "year"
      elsif at == "day"
        "year, month, day"
      else #default to month
        "year, month"
      end
    end

    def order_by
      "year desc, month desc, day desc" #always this, no matter the averaging time.
    end

    def get_by_category_data(averaging_time_string,table_format)
      column_names = current_user.transaction_categories.where(get_conditions(:column_names, :by_category)).select("id as column_id, name as column_name").order(:order_in_list).all
      row_names = current_user.transactions.where(get_conditions(:row_names, :by_category)).select("#{averaging_time_string}").group(group_by).order(order_by)
      data = current_user.transactions.where(get_conditions(:data, :by_category)).select("#{averaging_time_string}, sum(amount) as amount_sum, transaction_category_id as column_id").group("transaction_category_id, #{group_by}").order(order_by)

      if table_format
        return create_summary_table(row_names,column_names,data,:by_category)
      else
        return create_chart_data(column_names,data,:by_category)
      end

    end

    def get_by_account_data(averaging_time_string,table_format)
      column_names = current_user.accounts.where(get_conditions(:column_names, :by_account)).select("id as column_id, account_name as column_name").order(:order_in_list).all
      row_names = current_user.transactions.where(get_conditions(:row_names, :by_account)).select("#{averaging_time_string}").group(group_by).order(order_by)
      data = current_user.transactions.where(get_conditions(:data, :by_account)).select("#{averaging_time_string}, sum(amount) as amount_sum, account_id as column_id").group("account_id, #{group_by}").order(order_by)

      if table_format
        return create_summary_table(row_names,column_names,data,:by_account)
      else
        return create_chart_data(column_names,data,:by_account)
      end

    end

    def get_transaction_direction_data(averaging_time_string,table_format)

      c1 = ColumnNameAndID.new
      c2 = ColumnNameAndID.new
      c3 = ColumnNameAndID.new
      c1.column_id = c1.column_name = "income"
      c2.column_id = c2.column_name = "spending"
      c3.column_id = c3.column_name = "savings"
      column_names = [c1, c2, c3 ]
      row_names = current_user.transactions.where(get_conditions(:row_names, :by_transaction_direction)).select("#{averaging_time_string}").group(group_by).order(order_by)
      filter_string = ""
      filter_string += " AND year = #{params[:year]}" if params[:year].present?
      filter_string += " AND month = #{params[:month]}" if params[:month].present?
      filter_string += " AND day = #{params[:day]}" if params[:day].present?
      sql = "select #{averaging_time_string}, sum(income) as income, sum(spending) as spending, (sum(income) - sum(spending)) as savings FROM (select #{averaging_time_string}, case when amount >=0 then amount else 0 end as spending, case when amount < 0 then -1*amount else 0 end as income from transactions where user_id = #{current_user.id} #{ filter_string if !filter_string.empty?}) AS SpendingAndIncome GROUP BY #{group_by} ORDER BY #{order_by}"
      data = ActiveRecord::Base.connection.exec_query(sql).rows

      if table_format
        return create_summary_table(row_names,column_names,data,:by_transaction_direction)
      else
        return create_chart_data(column_names,data,:by_transaction_direction)
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

    def create_summary_table(row_names, column_names, data, summary_type)
      row_count = row_names.each.count
      column_count = column_names.each.count
      st = SummaryTable.new(row_count, column_count)
      rows_hash = {}
      columns_hash = {}

      index=0
      row_names.each do |r|
        row_name = get_row_name(r.year, r.month, r.day)
        rows_hash[row_name] = index
        st.set_header_text(:row, index, row_name)
        href = transactions_path + get_query_string(r.year, r.month, r.day, summary_type, nil)
        st.set_header_href(:row, index, href)
        st.set_row_numeric_value(index,DateTime.new(r.year,r.month || 1, r.day || 1))
        index += 1
      end

      index=0
      column_names.each do |c|
        columns_hash[c.column_id] = index
        st.set_header_text(:column,index, c.column_name)
        href = transactions_path + get_query_string(nil, nil, nil, summary_type, c.column_id)
        st.set_header_href(:column, index, href)
        index += 1
      end


      if summary_type == :by_transaction_direction
        #this type uses custom sql, so the data is in a different structure.
        data.each do |d|
          row = rows_hash[get_row_name(d[0], d[1], d[2])]
          href = transactions_path + get_query_string(d[0], d[1], d[2], nil, nil)
          #income
          st.set_text(row, 0, d[3], d[3].to_f)
          st.set_href(row,0,href)
          #spending
          st.set_text(row, 1, d[4], d[4].to_f)
          st.set_href(row,1,href)
          #savings
          st.set_text(row, 2, d[5], d[5].to_f)
          st.set_href(row,2,href)
        end
      else
        data.each do |d|
          row = rows_hash[get_row_name(d.year, d.month, d.day)]
          col_id = nil_to_zero(d.column_id)
          column = columns_hash[col_id]
          st.set_text(row, column, d.amount_sum, d.amount_sum.to_f)
          href = transactions_path + get_query_string(d.year, d.month, d.day, summary_type, d.column_id)
          st.set_href(row,column,href)
        end
      end

      return st
    end



    def get_query_string(year,month,day,summary_type,column_id)
      qs = []
      qs << "year=#{year}" if year.present?
      qs << "month=#{month}" if month.present?
      qs << "day=#{day}" if day.present?
      qs << "account_id=#{column_id}" if summary_type == :by_account and column_id.present?
      qs << "transaction_category_id=#{column_id}" if summary_type == :by_category and column_id.present?
      if qs.length > 0
        "?" + qs.join("&")
      else
        "" #nil
      end
    end

    def get_row_name(year, month, day)
      "#{(month.to_s + '/') if month.present?}#{(day.to_s + '/') if day.present?}#{year}"
    end

    def search_params(query_type)
      if query_type == :column_names
          params.permit(:account_id, :transaction_category_id)
      elsif query_type == :date_only
        params.permit(:month, :day, :year)
      else
         params.permit(:month, :day, :year, :account_id, :transaction_category_id)
      end
    end

    def get_conditions(query_type, summary_type)

      search_terms = Transaction.new(search_params(query_type))

      conditions = {}
      conditions_string = []

      conditions[:month] = search_terms.month if search_terms.month.present?
      conditions_string << "month = :month" if search_terms.month.present?

      conditions[:day] = search_terms.day if search_terms.day.present?
      conditions_string << "day = :day" if search_terms.day.present?

      conditions[:year] = search_terms.year if search_terms.year.present?
      conditions_string << "year = :year" if search_terms.year.present?

      if summary_type == :by_account then
        id_field_name = query_type == :column_names ? "id" : "account_id"
        conditions[:account_id] = search_terms.account_id if search_terms.account_id.present?
        conditions_string << "#{id_field_name} = :account_id" if search_terms.account_id.present?
      end

      if summary_type == :by_category then
        id_field_name = query_type == :column_names ? "id" : "transaction_category_id"
        conditions[:transaction_category_id] = search_terms.transaction_category_id if search_terms.transaction_category_id.present?
        conditions_string << "#{id_field_name} = :transaction_category_id" if search_terms.transaction_category_id.present?
      end

      return [conditions_string.join(" AND "), conditions]
    end

end
