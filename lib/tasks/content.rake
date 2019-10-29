namespace :content do
  desc "保存されている企画関係のデータをダンプする"
  task :export => :environment do
    file = File.open(".backup/contents.json","w")
    file.puts(Content.all.to_json)
  end

  desc "企画関係のデータを読み込んで上書きする"
  task :import => :environment do
    file = File.open(".backup/contents.json","r")
    dict = JSON.parse(file.read)

    Content.all.destroy_all
    dict.each do|content|
      new_content = Content.new
      if !content["ucode"].present? then
        allocate_ucode = Ucode.find_by_allocated(false)
        allocate_ucode.allocated = true
        allocate_ucode.save()

        new_content.ucode = [allocate_ucode.ucode]
      else
        new_content.ucode = content["ucode"]

        new_content.ucode.each do|ucode|
          target_ucode_data = Ucode.find_by_ucode(ucode)
          if !target_ucode_data.present? then
            next
          end

          target_ucode_data.allocated = true
          target_ucode_data.save()
        end
      end
      new_content.organizer = content["organizer"]
      new_content.place = content["place"]
      new_content.description = content["description"]
      new_content.title = content["title"]

      puts "add #{content["title"]}"
      new_content.save()
    end
  end
end
