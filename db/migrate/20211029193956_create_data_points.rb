class CreateDataPoints < ActiveRecord::Migration[6.1]
  def change
    create_table :data_points do |t|
      t.belongs_to :user
      t.belongs_to :workout_route
      t.belongs_to :data_type, index: { name: 'index_adtv_on_adt' }
      t.belongs_to :dropdown_option, index: { name: 'index_adtv_on_adto' }
      t.text :text_value
      t.decimal :decimal_value

      t.timestamps
    end
  end
end
