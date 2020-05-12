# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_11_185725) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fb_ads", force: :cascade do |t|
    t.string "uid"
    t.string "campaign_name"
    t.string "interests"
    t.integer "gender"
    t.string "headline"
    t.text "ptext"
    t.string "video_url"
    t.string "thumbnail_url"
    t.string "video_id"
    t.string "pixel_id"
    t.string "countries"
    t.string "creative_id"
    t.string "campaign_id"
    t.string "ad_set_id"
    t.string "ad_id"
    t.integer "result"
    t.string "result_status"
    t.datetime "start_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "fb_users", primary_key: "sno", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "token"
    t.string "ad_account_id"
    t.string "page_id"
    t.string "url"
    t.integer "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_fb_users_on_uid", unique: true
  end

end
