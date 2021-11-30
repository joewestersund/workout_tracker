class ChangeDataTypeUnitToUnits < ActiveRecord::Migration[6.1]
  def change
    rename_column :data_types, :unit, :units
  end
end
