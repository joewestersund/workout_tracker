class CreateDataTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :data_types do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.string :name
      t.string :field_type
      t.string :unit
      t.text :description
      t.integer :order_in_list
      t.boolean :active

      t.timestamps
    end
    add_index :data_types, [:user_id, :workout_type_id, :order_in_list], name: 'index_adt_on_user_and_workout_type_and_order'
  end
end
