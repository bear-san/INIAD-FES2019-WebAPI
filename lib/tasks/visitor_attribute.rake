namespace :visitor_attribute do
  desc "保存されている来場者属性関係のデータをダンプする"
  task :export => :environment do
    file = File.open(".backup/visitor_attribute.json","w")
    visitor_attributes = []
    VisitorAttribute.all.each do |visitor_attribute|
      visitor_attributes.append(visitor_attribute)
    end

    file.write(visitor_attributes.to_json)
  end

  desc "来場者属性関係のデータを読み込んで上書きする"
  task :import => :environment do
    file = File.open(".backup/visitor_attribute.json","r")
    dict = JSON.parse(file.read)

    VisitorAttribute.all.destroy_all
    dict.each do|visitor|
      new_attribute = VisitorAttribute.new
      new_attribute.user_id = visitor["user_id"]
      new_attribute.visited_at = visitor["visited_at"]
      new_attribute.visitor_attribute = visitor["visitor_attribute"]
      new_attribute.action_history = visitor["action_history"]
      new_attribute.enquete = visitor["enquete"]

      puts "add #{visitor["user_id"]}"
      new_attribute.save()
    end
  end
end
