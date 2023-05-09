class RemoveInvoiceIdFromRooms < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :invoice_id, :integer
  end
end
