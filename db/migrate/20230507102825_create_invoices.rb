class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.integer :room_id
      t.float :amount_due
      t.boolean :paid

      t.timestamps
    end
  end
end
