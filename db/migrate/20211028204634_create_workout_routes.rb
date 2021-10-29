class CreateWorkoutRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :workout_routes do |t|
      t.belongs_to :user
      t.belongs_to :workout
      t.belongs_to :route
      t.int :repetitions
      t.decimal :distance
      t.decimal :pace    # minutes/mile as a decimal. So 8.5 = 8 minutes 30 seconds per mile.
      t.decimal :duration
      t.int :heart_rate
      t.text :description

      t.timestamps
    end
    add_index :workout_routes, :workout_id
  end
end
