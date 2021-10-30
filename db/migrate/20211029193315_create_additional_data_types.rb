class CreateAdditionalDataTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_data_types do |t|
      t.belongs_to :user
      t.belongs_to :workout_type
      t.string :data_type_name
      t.integer :order_in_list

      t.timestamps
    end
    add_index :additional_data_types, [:user_id, :workout_type_id, :order_in_list], name: 'index_adt_on_user_and_workout_type_and_order'
  end
end
