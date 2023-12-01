class AddCheckInToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :check_in_date, :date
    add_column :requests, :check_out_date, :date
  end
end
