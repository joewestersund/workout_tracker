class AddDayToWorkouts < ActiveRecord::Migration[6.1]
  def up
    add_column :workouts, :day, :integer

    Workout.all.each { |w| w.save}   # trigger the new day field to be filled in
  end

  def down
    remove_column :workouts, :day
  end
end
