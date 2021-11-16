json.routes do
  json.array! @routes, partial: "routes/route", as: :route
end

json.data_types do
  json.array! @data_types, partial: "routes/data_type", as: :data_type
end
