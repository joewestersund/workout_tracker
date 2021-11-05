class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.string :remember_token
      t.string :reset_password_token
      t.datetime :password_reset_sent_at
      t.string :time_zone
      t.boolean :activated

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
