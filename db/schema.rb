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

ActiveRecord::Schema.define(version: 2023_07_24_073002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", id: :serial, force: :cascade do |t|
    t.integer "badge_id"
    t.integer "user_id"
    t.integer "prestige"
    t.date "date_received"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badge_maps", id: :serial, force: :cascade do |t|
    t.integer "badge_id"
    t.integer "challenge_id"
    t.integer "required_score"
    t.integer "prestige"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badges", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "avatar"
    t.string "direct_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nsfw_level", default: 1, null: false
    t.integer "challenge_id"
    t.index ["name"], name: "index_badges_on_name", unique: true
  end

  create_table "boards", force: :cascade do |t|
    t.string "title"
    t.integer "permission_level"
    t.string "alias"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alias"], name: "index_boards_on_alias"
  end

  create_table "challenge_entries", id: :serial, force: :cascade do |t|
    t.integer "challenge_id"
    t.integer "submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "challenges", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.boolean "streak_based"
    t.boolean "rejoinable"
    t.integer "postfrequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "seasonal", default: false
    t.integer "creator_id"
    t.integer "nsfw_level", default: 1, null: false
    t.boolean "soft_deleted", default: false, null: false
    t.integer "soft_deleted_by"
    t.boolean "is_site_challenge", default: false, null: false
    t.index ["name"], name: "index_challenges_on_name"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "body"
    t.string "source_type"
    t.integer "source_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "soft_deleted", default: false, null: false
    t.integer "soft_deleted_by"
    t.boolean "anonymous", default: false
    t.index ["source_type", "source_id"], name: "index_comments_on_source_type_and_source_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.string "title", null: false
    t.integer "nsfw_level", null: false
    t.bigint "user_id"
    t.boolean "locked", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "board_id"
    t.boolean "pinned", default: false, null: false
    t.boolean "allow_anon", default: false
    t.boolean "anonymous", default: false
    t.index ["board_id"], name: "index_discussions_on_board_id"
    t.index ["user_id"], name: "index_discussions_on_user_id"
  end

  create_table "followers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "following_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["following_id"], name: "index_followers_on_following_id"
    t.index ["user_id"], name: "index_followers_on_user_id"
  end

  create_table "house_participations", force: :cascade do |t|
    t.integer "house_id", null: false
    t.date "join_date", null: false
    t.integer "score", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_house_participations_on_user_id"
  end

  create_table "houses", force: :cascade do |t|
    t.text "house_name", null: false
    t.date "house_start", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "moderator_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "time_zone", null: false
    t.text "active_hours", null: false
    t.text "why_mod", null: false
    t.text "past_experience", null: false
    t.text "how_long", null: false
    t.text "why_dad", null: false
    t.text "anything_else"
    t.index ["user_id"], name: "index_moderator_applications_on_user_id"
  end

  create_table "moderator_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "target_type"
    t.bigint "target_id"
    t.index ["target_type", "target_id"], name: "index_moderator_logs_on_target_type_and_target_id"
    t.index ["user_id"], name: "index_moderator_logs_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "source_type"
    t.integer "source_id"
    t.string "body"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["source_type", "source_id"], name: "index_notifications_on_source_type_and_source_id"
  end

  create_table "participations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "challenge_id"
    t.boolean "active"
    t.integer "score"
    t.boolean "eliminated"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "next_submission_date"
    t.date "last_submission_date"
    t.boolean "submitted"
    t.date "processed"
  end

  create_table "patch_entries", id: :serial, force: :cascade do |t|
    t.integer "patchnote_id"
    t.string "body"
    t.integer "importance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patch_notes", id: :serial, force: :cascade do |t|
    t.string "before"
    t.string "after"
    t.string "patch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["patch"], name: "index_patch_notes_on_patch", unique: true
  end

  create_table "site_bans", force: :cascade do |t|
    t.bigint "user_id"
    t.date "expiration", null: false
    t.string "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_site_bans_on_user_id"
  end

  create_table "site_statuses", id: :serial, force: :cascade do |t|
    t.date "current_rollover"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "drawing"
    t.integer "nsfw_level", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "description"
    t.integer "time"
    t.boolean "commentable"
    t.integer "num_comments", default: 0, null: false
    t.boolean "is_animated_gif", default: false, null: false
    t.boolean "soft_deleted", default: false, null: false
    t.boolean "approved", default: true, null: false
    t.integer "soft_deleted_by"
    t.boolean "allow_anon", default: false
  end

  create_table "user_feedbacks", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.string "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_feedbacks_on_user_id"
  end

  create_table "user_sessions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "avatar"
    t.integer "longest_streak", default: 0
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.integer "nsfw_level", default: 1, null: false
    t.boolean "is_admin"
    t.integer "dad_frequency"
    t.integer "new_frequency"
    t.string "display_name"
    t.integer "current_streak", default: 0
    t.integer "highest_level", default: 0
    t.boolean "verified", default: false, null: false
    t.boolean "email_verified", default: false, null: false
    t.string "email_pending_verification"
    t.string "email_verification_digest"
    t.datetime "email_verification_sent_at"
    t.string "x_site_auth_digest"
    t.boolean "is_moderator", default: false, null: false
    t.boolean "approved", default: false, null: false
    t.boolean "marked_for_death", default: false, null: false
    t.boolean "is_developer", default: false, null: false
    t.boolean "marked_for_deletion", default: false, null: false
    t.date "deletion_date"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "challenges", "users", column: "creator_id"
  add_foreign_key "discussions", "boards"
  add_foreign_key "discussions", "users"
  add_foreign_key "house_participations", "users"
  add_foreign_key "moderator_applications", "users"
  add_foreign_key "moderator_logs", "users"
  add_foreign_key "site_bans", "users"
  add_foreign_key "user_feedbacks", "users"
  add_foreign_key "user_sessions", "users"
end
