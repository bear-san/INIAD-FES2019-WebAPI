class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.string :ucode
      t.string :title
      t.string :description
      t.string :organizer
      t.string :place

      t.timestamps
    end
  end
end