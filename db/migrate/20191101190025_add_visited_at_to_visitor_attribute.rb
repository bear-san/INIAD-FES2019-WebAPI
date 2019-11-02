class AddVisitedAtToVisitorAttribute < ActiveRecord::Migration[5.2]
  def change
    add_column :visitor_attributes, :visited_at, :string, :array => true, :default => []
  end
end
