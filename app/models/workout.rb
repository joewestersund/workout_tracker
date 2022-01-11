# == Schema Information
#
# Table name: workouts
#
#  id              :bigint           not null, primary key
#  day             :integer
#  month           :integer
#  week            :integer
#  week_year       :integer
#  workout_date    :date
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint
#  workout_type_id :bigint
#
# Indexes
#
#  index_workouts_on_user_id                             (user_id)
#  index_workouts_on_user_id_and_week_year_and_week      (user_id,week_year DESC,week DESC)
#  index_workouts_on_user_id_and_workout_date            (user_id,workout_date DESC)
#  index_workouts_on_user_id_and_year_and_month_and_day  (user_id,year DESC,month DESC,day DESC)
#  index_workouts_on_workout_type_id                     (workout_type_id)
#
class Workout < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :workout_routes, dependent: :destroy

  before_save :set_year_month_week_day

  validates :user_id, presence: true

  def set_year_month_week_day
    self.year = self.workout_date.year
    self.month = self.workout_date.month
    self.week = self.workout_date.cweek
    if self.month == 1 && self.week > 50
      # the first few days of the year may be part of the week from the previous year
      self.week_year = self.year - 1
    else
      self.week_year = self.year
    end
    self.day = self.workout_date.day
  end

end
