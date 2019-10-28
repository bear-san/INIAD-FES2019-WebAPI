class CreateFloorImages < ActiveRecord::Migration[5.2]
  def change
    create_table :floor_images do |t|
      t.integer :floor
      t.string :image_url

      t.timestamps
    end
  end
end
