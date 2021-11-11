class CreateDropdownOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :dropdown_options do |t|
      t.belongs_to :user
      t.belongs_to :data_type
      t.string :name
      t.integer :order_in_list

      t.timestamps
    end
    add_index :dropdown_options, [:user_id, :data_type_id, :order_in_list], name: 'index_adto_on_user_and_adt_and_order'
  end
end
