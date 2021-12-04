# == Schema Information
#
# Table name: workouts
#
#  id              :bigint           not null, primary key
#  day             :integer
#  month           :integer
#  week            :integer
#  workout_date    :date
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_workouts_on_user_id                              (user_id)
#  index_workouts_on_user_id_and_workout_date             (user_id,workout_date DESC)
#  index_workouts_on_user_id_and_year_and_month_and_week  (user_id,year DESC,month DESC,week DESC)
#  index_workouts_on_workout_type_id                      (workout_type_id)
#
require "test_helper"

class WorkoutTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
