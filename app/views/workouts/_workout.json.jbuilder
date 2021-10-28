json.extract! workout, :id, :workout_date, :workout_type_id, :user_id, :created_at, :updated_at
json.url workout_url(workout, format: :json)
