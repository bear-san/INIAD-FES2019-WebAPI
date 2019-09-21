class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id, :null => false
      t.string :secret, :null => false
      t.string :role, :array => true
      t.string :device_type
      t.string :notification_token

      t.timestamps
    end
  end
end
