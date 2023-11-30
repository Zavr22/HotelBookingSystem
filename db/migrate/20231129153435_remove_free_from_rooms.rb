class RemoveFreeFromRooms < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :free, :boolean
  end
end
