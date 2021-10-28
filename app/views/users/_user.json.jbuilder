json.extract! user, :id, :email, :name, :password_digest, :remember_token, :reset_password_token, :password_reset_sent_at, :time_zone, :created_at, :updated_at
json.url user_url(user, format: :json)
