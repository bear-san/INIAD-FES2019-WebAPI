namespace :ucode do
  desc "保存されているucode関係のデータをダンプする"
  task :export => :environment do
    file = File.open(".backup/ucode.json","w")
    ucodes = []
    Ucode.all.each do |ucode|
      ucodes.append(ucode.ucode)
    end

    file.write(ucodes)
  end

  desc "ucode関係のデータを読み込んで上書きする"
  task :import => :environment do
    file = File.open(".backup/ucode.json","r")
    dict = JSON.parse(file.read)

    Ucode.all.destroy_all
    dict.each do|ucode|
      new_ucode = Ucode.new
      new_ucode.ucode = ucode
      if Content.find_by_ucode(ucode).present? or Room.where("ucode @> ARRAY[?]::varchar[]",[ucode]).present? or Organization.find_by_ucode(ucode).present? then
        new_ucode.allocated = true
      else
        new_ucode.allocated = false
      end

      new_ucode.save()
    end
  end
end
