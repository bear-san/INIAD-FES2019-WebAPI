namespace :room do
  desc "保存されている部屋関係のデータをダンプする"
  task :export => :environment do
    file = File.open(".backup/rooms.json","w")
    file.puts(Room.all.to_json)
  end

  desc "部屋関係のデータを読み込んで上書きする"
  task :import => :environment do
    file = File.open(".backup/rooms.json","r")
    dict = JSON.parse(file.read)

    Room.all.destroy_all
    dict.each do|room|
      new_room = Room.new
      if !room["ucode"].present? then
        allocate_ucode = Ucode.find_by_allocated(false)
        allocate_ucode.allocated = true
        allocate_ucode.save()

        new_room.ucode = [allocate_ucode.ucode]
      else
        new_room.ucode = room["ucode"]

        new_room.ucode.each do|ucode|
          target_ucode_data = Ucode.find_by_ucode(ucode)
          if !target_ucode_data.present? then
            next
          end

          target_ucode_data.allocated = true
          target_ucode_data.save()
        end
      end

      new_room.room_num = room["room_num"]
      new_room.related_rooms = room["related_rooms"]
      new_room.floor = room["floor"]
      new_room.room_color = room["room_color"]
      new_room.door_name = room["door_name"]

      puts "add #{new_room["room_num"]}"
      new_room.save()
    end
  end
end
