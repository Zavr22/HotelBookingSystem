class AddIsDeletedToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :is_deleted, :boolean
  end
end
