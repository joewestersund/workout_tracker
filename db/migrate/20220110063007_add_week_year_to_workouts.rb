class AddWeekYearToWorkouts < ActiveRecord::Migration[6.1]
  def up
    add_column :workouts, :week_year, :integer

    Workout.all.each { |w| w.save}   # trigger the new day field to be filled in

    add_index :workouts, [:user_id, :week_year, :week], order: {user_id: :asc, week_year: :desc, week: :desc}
    add_index :workouts, [:user_id, :year, :month, :day], order: {user_id: :asc, year: :desc, month: :desc, day: :desc}

    #added in CreateWorkouts migration but not useful, so remove
    remove_index :workouts, [:user_id, :year, :month, :week], order: {user_id: :asc, year: :desc, month: :desc, week: :desc}

  end

  def down
    remove_index :workouts, [:user_id, :week_year, :week], order: {user_id: :asc, week_year: :desc, week: :desc}
    remove_index :workouts, [:user_id, :year, :month, :day], order: {user_id: :asc, year: :desc, month: :desc, day: :desc}
    remove_column :workouts, :week_year

    #in order to reverse migration, would need to re-add this
    add_index :workouts, [:user_id, :year, :month, :week], order: {user_id: :asc, year: :desc, month: :desc, week: :desc}
  end
end
