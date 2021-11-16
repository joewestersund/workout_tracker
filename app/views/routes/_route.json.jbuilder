json.id route.id
json.name route.name
json.description route.description
json.default_data_points route.default_data_points do |dp|
  json.data_type_id dp.data_type.id
  json.data_type_name dp.data_type.name
  json.value dp.value_to_s
end
