class CreateUcodes < ActiveRecord::Migration[5.2]
  def change
    create_table :ucodes do |t|
      t.string :ucode, :null => false
      t.boolean :allocated, :null => false, :default => false
      t.timestamps
    end
  end
end