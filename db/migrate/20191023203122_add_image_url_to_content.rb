class AddImageUrlToContent < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :image_url, :string
  end
end
