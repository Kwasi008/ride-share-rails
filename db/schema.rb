# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_10_215731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "drivers", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.integer "radius", default: 100
    t.boolean "is_active", default: true
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.datetime "token_created_at"
    t.string "application_state", default: "pending"
    t.boolean "background_check", default: false, null: false
    t.boolean "admin_sign_up", default: true
    t.index ["auth_token", "token_created_at"], name: "index_drivers_on_auth_token_and_token_created_at"
    t.index ["organization_id"], name: "index_drivers_on_organization_id"
  end

  create_table "location_relationships", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "driver_id"
    t.bigint "rider_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", null: false
    t.index ["driver_id"], name: "index_location_relationships_on_driver_id"
    t.index ["location_id"], name: "index_location_relationships_on_location_id"
    t.index ["organization_id"], name: "index_location_relationships_on_organization_id"
    t.index ["rider_id"], name: "index_location_relationships_on_rider_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "notes"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.boolean "use_tokens", default: false
    t.boolean "send_notifications"
    t.boolean "use_rider_app", default: true
  end

  create_table "recurring_patterns", force: :cascade do |t|
    t.bigint "schedule_window_id"
    t.integer "separation_count"
    t.integer "day_of_week"
    t.integer "week_of_month"
    t.integer "month_of_year"
    t.string "type_of_repeating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_window_id"], name: "index_recurring_patterns_on_schedule_window_id"
  end

  create_table "ride_logs", force: :cascade do |t|
    t.string "action_type"
    t.string "original_status"
    t.string "new_status"
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "ride_id", null: false
    t.index ["ride_id"], name: "index_ride_logs_on_ride_id"
    t.index ["user_id"], name: "index_ride_logs_on_user_id"
  end

  create_table "riders", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "notes"
    t.index ["organization_id"], name: "index_riders_on_organization_id"
  end

  create_table "rides", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "rider_id"
    t.bigint "driver_id"
    t.datetime "pick_up_time"
    t.bigint "start_location_id"
    t.bigint "end_location_id"
    t.text "reason"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "round_trip", default: false, null: false
    t.string "expected_wait_time"
    t.date "completed_at"
    t.integer "outbound"
    t.integer "return"
    t.boolean "same_driver", default: false
    t.float "pickup_to_dropoff_distance"
    t.datetime "pickup_to_dropoff_time"
    t.string "notes"
    t.string "cancellation_reason"
    t.index ["driver_id"], name: "index_rides_on_driver_id"
    t.index ["end_location_id"], name: "index_rides_on_end_location_id"
    t.index ["organization_id"], name: "index_rides_on_organization_id"
    t.index ["rider_id"], name: "index_rides_on_rider_id"
    t.index ["start_location_id"], name: "index_rides_on_start_location_id"
  end

  create_table "schedule_window_exceptions", force: :cascade do |t|
    t.bigint "schedule_window_id"
    t.boolean "is_canceled"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedule_window_id"], name: "index_schedule_window_exceptions_on_schedule_window_id"
  end

  create_table "schedule_windows", force: :cascade do |t|
    t.bigint "driver_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "location_id"
    t.boolean "is_recurring", default: false
    t.index ["driver_id"], name: "index_schedule_windows_on_driver_id"
    t.index ["location_id"], name: "index_schedule_windows_on_location_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.bigint "rider_id"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "used_at"
    t.boolean "is_valid", default: true
    t.datetime "updated_at", null: false
    t.integer "ride_id"
    t.index ["rider_id"], name: "index_tokens_on_rider_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "organization_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "driver_id"
    t.string "car_make"
    t.string "car_model"
    t.string "car_color"
    t.integer "car_year"
    t.string "car_plate"
    t.integer "seat_belt_num"
    t.string "insurance_provider"
    t.date "insurance_start"
    t.date "insurance_stop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "car_state"
    t.index ["driver_id"], name: "index_vehicles_on_driver_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ride_logs", "rides"
  add_foreign_key "ride_logs", "users"
end
