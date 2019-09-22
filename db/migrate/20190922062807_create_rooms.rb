class CreateRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :rooms do |t|
      t.string :room_num
      t.string :ucode, :array => true
      t.string :floor
      t.string :related_rooms, :array => true

      t.timestamps
    end
  end
end
