class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :capacity
      t.string :apart_class
      t.integer :duration

      t.timestamps
    end
  end
end
