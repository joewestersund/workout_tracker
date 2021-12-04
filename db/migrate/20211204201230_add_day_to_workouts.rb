class AddDayToWorkouts < ActiveRecord::Migration[6.1]
  def change
    add_column :workouts, :day, :integer
  end
end
