json.workout_routes do
  json.array! @workout_routes, partial: "workout_types/workout_route", as: :workout_route
end