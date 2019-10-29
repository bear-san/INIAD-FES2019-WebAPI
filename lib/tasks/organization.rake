namespace :organization do
  desc "保存されている組織関係のデータをダンプする"
  task :export => :environment do
    file = File.open(".backup/organizations.json","w")
    file.puts(Organization.all.to_json)
  end

  desc "組織関係のデータを読み込んで上書きする"
  task :import => :environment do
    file = File.open(".backup/organizations.json","r")
    dict = JSON.parse(file.read)

    Organization.all.destroy_all
    dict.each do|org|
      organization = Organization.new
      if !org["ucode"].present? then
        allocate_ucode = Ucode.find_by_allocated(false)
        allocate_ucode.allocated = true
        allocate_ucode.save()

        organization.ucode = [allocate_ucode.ucode]
      else
        organization.ucode = room["ucode"]

        organization.ucode.each do|ucode|
          target_ucode_data = Ucode.find_by_ucode(ucode)
          if !target_ucode_data.present? then
            next
          end

          target_ucode_data.allocated = true
          target_ucode_data.save()
        end
      end
      organization.members = org["members"]
      organization.organization_name = org["organization_name"]

      puts "add #{org["organization_name"]}"
      organization.save()
    end
  end
end
