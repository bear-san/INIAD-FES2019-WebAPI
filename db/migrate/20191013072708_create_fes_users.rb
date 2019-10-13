class CreateFesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :fes_users do |t|
      t.string :iniad_id, :null => false
      t.string :devices, :array => true
      t.timestamps
    end
  end
end
