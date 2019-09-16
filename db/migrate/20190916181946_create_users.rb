class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :secret
      t.string :role, :array => true

      t.timestamps
    end
  end
end
