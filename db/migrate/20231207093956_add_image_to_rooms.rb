class AddImageToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :image_data, :jsonb
  end
end
