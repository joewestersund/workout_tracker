# == Schema Information
#
# Table name: workouts
#
#  id              :bigint           not null, primary key
#  month           :integer
#  week            :integer
#  workout_date    :datetime
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
class Workout < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :workout_routes, dependent: :destroy

  before_save :set_year_month_week

  validates :user_id, presence: true

  def set_year_month_week
    self.year = self.workout_date.year
    self.month = self.workout_date.month
    self.week = self.workout_date.cweek
  end

end
