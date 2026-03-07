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

ActiveRecord::Schema[7.2].define(version: 2024_03_06_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "number", null: false
    t.string "status", default: "pending", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.text "notes"
    t.date "order_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["number", "status", "order_date"], name: "index_orders_on_number_status_date"
    t.index ["number", "status"], name: "index_orders_on_number_status"
    t.index ["number"], name: "index_orders_on_number_unique", unique: true
    t.index ["order_date", "person_id"], name: "index_orders_on_date_person"
    t.index ["order_date", "status"], name: "index_orders_on_date_status"
    t.index ["order_date"], name: "index_orders_on_order_date"
    t.index ["person_id", "created_at"], name: "index_orders_on_person_created_at"
    t.index ["person_id", "number"], name: "index_orders_on_person_number"
    t.index ["person_id", "order_date", "status"], name: "index_orders_on_person_date_status"
    t.index ["person_id", "order_date"], name: "index_orders_on_person_date"
    t.index ["person_id", "status", "order_date"], name: "index_orders_on_person_status_date_alt"
    t.index ["person_id", "status"], name: "index_orders_on_person_status"
    t.index ["person_id"], name: "index_orders_on_person_id"
    t.index ["person_id"], name: "index_orders_on_person_id_fk"
    t.index ["status", "created_at"], name: "index_orders_on_status_created_at"
    t.index ["status", "order_date"], name: "index_orders_on_status_date_alt"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "people", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.string "company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["first_name", "last_name"], name: "index_people_on_first_name_and_last_name"
  end

  add_foreign_key "orders", "people"
end
