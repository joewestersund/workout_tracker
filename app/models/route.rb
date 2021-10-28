class Route < ApplicationRecord

  has_many :workout_routes

  belongs_to :user
  belongs_to :workout_type


end
