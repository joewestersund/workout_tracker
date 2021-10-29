class WorkoutType < ApplicationRecord
  belongs_to :user

  has_many :routes

  validates :user_id, presence: true
  validates :order_in_list, numericality: { only_integer: true, greater_than: 0}, uniqueness: {scope: :user_id }
end
