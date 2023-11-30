# frozen_string_literal: true

class AddTotalCountToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :total_count, :integer
  end
end
