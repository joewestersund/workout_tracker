class Workout < ApplicationRecord
  belongs_to :user
  belongs_to :workout_type

  has_many :workout_routes
  before_save :set_year_month_week

  validates :user_id, presence: true

  def set_year_month_week
    self.year = self.workout_date.year
    self.month = self.workout_date.month
    self.week = self.workout_date.cweek
  end

end
