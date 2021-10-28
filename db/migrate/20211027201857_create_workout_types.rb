class CreateWorkoutTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :workout_types do |t|
      t.belongs_to :user
      t.string :name
      t.int :order_in_list

      t.timestamps
    end
    add_index :workout_types, [:user_id, :order_in_list]
  end
end
