class CreatePushNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notifications do |t|
      t.string :title, :null => false, :default => ""
      t.string :message, :null => false, :default => ""
      t.string :target, :null => false, :default => "all"
      t.timestamp :issued_time
    end
  end
end
