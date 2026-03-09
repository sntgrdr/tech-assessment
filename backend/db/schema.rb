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

ActiveRecord::Schema[7.2].define(version: 2026_03_09_015347) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "external_identities", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "source", null: false
    t.string "external_id", null: false
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_external_identities_on_person_id"
    t.index ["source", "external_id"], name: "index_external_identities_on_source_and_external_id", unique: true
    t.index ["source"], name: "index_external_identities_on_source"
  end

  create_table "people", force: :cascade do |t|
    t.string "email", null: false
    t.string "phone"
    t.string "company"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "job_title"
    t.string "department"
    t.string "manager_email"
    t.date "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_people_on_lower_email", unique: true
    t.index ["company"], name: "index_people_on_company"
    t.index ["department"], name: "index_people_on_department"
    t.index ["job_title"], name: "index_people_on_job_title"
    t.index ["manager_email"], name: "index_people_on_manager_email"
    t.index ["phone"], name: "index_people_on_phone"
  end

  add_foreign_key "external_identities", "people"
end
