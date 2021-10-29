class CreateWorkouts < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.datetime :workout_date
      t.int :year
      t.int :month
      t.int :week

      t.timestamps
    end
    add_index :workouts, [:user_id, :workout_date], order: {user_id: :asc, workout_date: :desc}
    add_index :workouts, [:user_id, :year, :month, :week], order: {user_id: :asc, year: :desc, month: :desc, week: :desc}
  end
end
