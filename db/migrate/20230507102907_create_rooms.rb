class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :room_class
      t.integer :room_number
      t.boolean :free

      t.timestamps
    end
  end
end
