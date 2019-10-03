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

ActiveRecord::Schema.define(version: 2019_10_02_050823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contents", force: :cascade do |t|
    t.string "ucode"
    t.string "title"
    t.string "description"
    t.string "organizer"
    t.string "place"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "ucode"
    t.string "organization_name"
    t.string "members", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "room_num"
    t.string "ucode", array: true
    t.string "floor"
    t.string "door_name", array: true
    t.string "room_color"
    t.string "related_rooms", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "secret", null: false
    t.string "role", array: true
    t.boolean "is_visited", default: false, null: false
    t.string "device_type", null: false
    t.string "notification_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "visitor_attributes", force: :cascade do |t|
    t.string "user_id", null: false
    t.jsonb "visitor_attribute"
    t.jsonb "action_history"
    t.jsonb "enquete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
