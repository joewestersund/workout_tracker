json.route_id workout_route.route_id
json.route_name workout_route.route.name
json.data_points workout_route.data_points do |dp|
  dt = dp.data_type
  json.data_type_id dt.id
  json.data_type_name dt.name
  json.value dp.value_to_s
  if dt.is_dropdown?
    json.options dt.dropdown_options.order(:order_in_list) do |opt|
      json.option_id opt.id
      json.option_name opt.name
    end
  end
end
