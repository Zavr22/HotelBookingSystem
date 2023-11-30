class AddFreeCountToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :free_count, :integer
  end
end
