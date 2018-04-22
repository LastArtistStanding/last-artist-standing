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

ActiveRecord::Schema.define(version: 20180418215425) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", force: :cascade do |t|
    t.integer  "badge_id"
    t.integer  "user_id"
    t.integer  "prestige"
    t.date     "date_received"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "badge_maps", force: :cascade do |t|
    t.integer  "badge_id"
    t.integer  "challenge_id"
    t.integer  "required_score"
    t.integer  "prestige"
    t.string   "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "badges", force: :cascade do |t|
    t.string   "name"
    t.string   "avatar"
    t.string   "direct_image"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["name"], name: "index_badges_on_name", unique: true, using: :btree
  end

  create_table "challenge_entries", force: :cascade do |t|
    t.integer  "challenge_id"
    t.integer  "submission_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "streak_based"
    t.boolean  "rejoinable"
    t.integer  "postfrequency"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "seasonal",      default: false
    t.integer  "creator_id"
    t.index ["name"], name: "index_challenges_on_name", using: :btree
  end

  create_table "participations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "challenge_id"
    t.boolean  "active"
    t.integer  "score"
    t.boolean  "eliminated"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.date     "next_submission_date"
    t.date     "last_submission_date"
    t.boolean  "submitted"
  end

  create_table "patch_entries", force: :cascade do |t|
    t.integer  "patchnote_id"
    t.string   "body"
    t.integer  "importance"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "patch_notes", force: :cascade do |t|
    t.string   "before"
    t.string   "after"
    t.string   "patch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patch"], name: "index_patch_notes_on_patch", unique: true, using: :btree
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "drawing"
    t.integer  "nsfw_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest"
    t.string   "avatar"
    t.integer  "longest_streak",  default: 0
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "nsfw_level"
    t.boolean  "is_admin"
    t.integer  "dad_frequency"
    t.integer  "new_frequency"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
  end

end
