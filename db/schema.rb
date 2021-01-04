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

ActiveRecord::Schema.define(version: 2021_01_04_021016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "airings", force: :cascade do |t|
    t.bigint "show_id", null: false
    t.bigint "channel_id", null: false
    t.text "recurrence"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "timeslot", null: false
    t.integer "usual_block_length_in_minutes"
    t.index ["channel_id"], name: "index_airings_on_channel_id"
    t.index ["show_id"], name: "index_airings_on_show_id"
  end

  create_table "channels", force: :cascade do |t|
    t.integer "number", null: false
    t.string "short_name", limit: 5, null: false
    t.string "long_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["long_name"], name: "index_channels_on_long_name", unique: true
    t.index ["number"], name: "index_channels_on_number", unique: true
    t.index ["short_name"], name: "index_channels_on_short_name", unique: true
  end

  create_table "commercials", force: :cascade do |t|
    t.string "title"
    t.string "file_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title"], name: "index_commercials_on_title", unique: true
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.date "airdate", null: false
    t.text "timeslot", null: false
    t.bigint "show_id", null: false
    t.bigint "airing_id"
    t.integer "specificity_score", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_listing_id"
    t.index ["airing_id"], name: "index_listings_on_airing_id"
    t.index ["channel_id"], name: "index_listings_on_channel_id"
    t.index ["parent_listing_id"], name: "index_listings_on_parent_listing_id"
    t.index ["show_id"], name: "index_listings_on_show_id"
  end

  create_table "shows", force: :cascade do |t|
    t.string "title"
    t.string "base_dir"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["title"], name: "index_shows_on_title", unique: true
  end

  add_foreign_key "airings", "channels"
  add_foreign_key "airings", "shows"
  add_foreign_key "listings", "airings"
  add_foreign_key "listings", "channels"
  add_foreign_key "listings", "listings", column: "parent_listing_id"
  add_foreign_key "listings", "shows"
end
