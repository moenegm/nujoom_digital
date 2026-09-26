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

ActiveRecord::Schema[8.1].define(version: 2026_08_16_035255) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.time "end_time"
    t.bigint "provider_id", null: false
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_availabilities_on_provider_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.string "client_email"
    t.string "client_name"
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.text "note"
    t.bigint "provider_id", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["provider_id", "starts_at"], name: "index_bookings_on_provider_id_and_starts_at", unique: true
    t.index ["provider_id"], name: "index_bookings_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "availabilities", "providers"
  add_foreign_key "bookings", "providers"
end
