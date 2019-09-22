class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :ucode
      t.string :members, :array => true

      t.timestamps
    end
  end
end
