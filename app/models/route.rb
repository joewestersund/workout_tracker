class Route < ApplicationRecord

  has_many :workout_routes

  belongs_to :user
  belongs_to :workout_type

  validates :user_id, presence: true
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: :user_id }
end
