class CreateRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :routes do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.string :name
      t.text :description
      t.integer :order_in_list
      t.boolean :active

      t.timestamps
    end
    add_index :routes, [:user_id, :workout_type_id, :order_in_list]
  end
end
