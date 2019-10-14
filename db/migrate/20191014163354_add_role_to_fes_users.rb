class AddRoleToFesUsers < ActiveRecord::Migration[5.2]
  def change
    add_column(:fes_users, :role, :string, :array => true)
    add_column(:fes_users, :name, :string)
  end
end
