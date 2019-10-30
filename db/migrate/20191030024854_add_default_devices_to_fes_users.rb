class AddDefaultDevicesToFesUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :fes_users, :devices, :string, :array => true, :default => []
  end
end
