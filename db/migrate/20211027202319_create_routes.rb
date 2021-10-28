class CreateRoutes < ActiveRecord::Migration[6.1]
  def change
    create_table :routes do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.string :name
      t.float :distance
      t.int :order_in_list

      t.timestamps
    end
    add_index :routes, [:user_id, :order_in_list]
  end
end
