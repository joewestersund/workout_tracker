class CreateDefaultDataPoints < ActiveRecord::Migration[6.1]
  def change
    create_table :default_data_points do |t|
      t.belongs_to :user
      t.belongs_to :route
      t.belongs_to :data_type, index: { name: 'index_ddp_on_dt' }
      t.belongs_to :dropdown_option, index: { name: 'index_ddp_on_do' }
      t.text :text_value
      t.decimal :decimal_value

      t.timestamps
    end
  end
end
