class CreateRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :routes do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.string :name
      t.decimal :distance
      t.text :description
      t.integer :order_in_list

      t.timestamps
    end
    add_index :routes, [:user_id, :workout_type_id, :order_in_list]
  end
end
