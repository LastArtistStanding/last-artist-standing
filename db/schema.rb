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

ActiveRecord::Schema.define(version: 20191023034006) do

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
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "nsfw_level",   default: 1
    t.integer  "challenge_id"
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
    t.integer  "nsfw_level",    default: 1
    t.index ["name"], name: "index_challenges_on_name", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.string   "body"
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["source_type", "source_id"], name: "index_comments_on_source_type_and_source_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "body"
    t.datetime "read_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "url"
    t.index ["source_type", "source_id"], name: "index_notifications_on_source_type_and_source_id", using: :btree
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
    t.date     "processed"
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
    t.string   "title"
    t.index ["patch"], name: "index_patch_notes_on_patch", unique: true, using: :btree
  end

  create_table "site_statuses", force: :cascade do |t|
    t.date     "current_rollover"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "drawing"
    t.integer  "nsfw_level"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "title"
    t.string   "description"
    t.integer  "time"
    t.boolean  "commentable"
    t.integer  "num_comments",    default: 0,     null: false
    t.boolean  "is_animated_gif", default: false, null: false
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
    t.string   "display_name"
    t.integer  "current_streak",  default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
  end

end
