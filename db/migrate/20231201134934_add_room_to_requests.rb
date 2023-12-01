class AddRoomToRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :requests, :room, null: true, foreign_key: true
  end
end
