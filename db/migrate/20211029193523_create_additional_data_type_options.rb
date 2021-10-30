class CreateAdditionalDataTypeOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_data_type_options do |t|
      t.belongs_to :user
      t.belongs_to :additional_data_type, index: { name: 'index_adto_on_adt' }
      t.string :name
      t.integer :order_in_list

      t.timestamps
    end
    add_index :additional_data_type_options, [:user_id, :additional_data_type_id, :order_in_list], name: 'index_adto_on_user_and_adt_and_order'
  end
end
