# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_07_102907) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "invoices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "request_id", null: false
    t.integer "room_id"
    t.float "amount_due"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_invoices_on_request_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "capacity"
    t.string "apart_class"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.string "room_class"
    t.integer "room_number"
    t.boolean "free"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_rooms_on_invoice_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "password"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "invoices", "requests"
  add_foreign_key "invoices", "users"
  add_foreign_key "requests", "users"
  add_foreign_key "rooms", "invoices"
end
