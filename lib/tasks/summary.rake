namespace :summary do
  desc "来場者データを、コンテンツデータに紐付けする"
  task :tying => :environment do
    Content.all.each do|content|
      content.visitors = []
      content.save()
    end

    VisitorAttribute.all.each do|attribute|
      if !attribute.action_history["visit"].present? then
        next
      end

      attribute.action_history["visit"].each do|history|
        target_content = Content.find_by_ucode(history["ucode"])
        if !target_content.present? then
          next
        end

        target_content.visitors.append({"user_id" => attribute.user_id, "timestamp" => history["timestamp"]})
        target_content.save()
      end
    end
  end
end