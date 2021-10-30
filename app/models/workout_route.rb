# == Schema Information
#
# Table name: workout_routes
#
#  id          :bigint           not null, primary key
#  description :text
#  distance    :decimal(, )
#  duration    :decimal(, )
#  heart_rate  :integer
#  pace        :decimal(, )
#  repetitions :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  route_id    :bigint
#  user_id     :bigint
#  workout_id  :bigint
#
# Indexes
#
#  index_workout_routes_on_route_id    (route_id)
#  index_workout_routes_on_user_id     (user_id)
#  index_workout_routes_on_workout_id  (workout_id)
#
class WorkoutRoute < ApplicationRecord
  belongs_to :user
  belongs_to :workout
  belongs_to :route

  validates :user_id, presence: true

end
