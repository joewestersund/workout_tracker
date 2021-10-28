class CreateWorkouts < ActiveRecord::Migration[6.1]
  def change
    create_table :workouts do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.datetime :workout_date

      t.timestamps
    end
    add_index :workouts, [:user_id, :workout_date]
  end
end
