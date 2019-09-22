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
      new_content.id = content["id"]
      new_content.ucode = content["ucode"]
      new_content.organizer = content["organizer"]
      new_content.place = content["place"]
      new_content.description = content["description"]
      new_content.title = content["title"]
      new_content.save()
    end
  end
end
