class DropColumnImageDataFromRooms < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :image_data, :jsonb
  end
end
