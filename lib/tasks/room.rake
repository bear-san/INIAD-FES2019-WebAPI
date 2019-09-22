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
      new_room.id = room["id"]
      new_room.room_num = room["room_num"]
      new_room.ucode = room["ucode"]
      new_room.related_rooms = room["related_rooms"]
      new_room.floor = room["floor"]

      new_room.save()
    end
  end
end
