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
      organization.ucode = org["ucode"]
      organization.members = org["members"]
      organization.organization_name = org["organization_name"]

      organization.save()
    end
  end
end
