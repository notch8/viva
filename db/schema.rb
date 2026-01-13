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

ActiveRecord::Schema[7.0].define(version: 2026_01_13_212912) do
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_bookmarks_on_question_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "export_loggers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "export_type", null: false
    t.bigint "question_id", null: false
    t.bigint "user_id", null: false
    t.index ["question_id"], name: "index_export_loggers_on_question_id"
    t.index ["user_id"], name: "index_export_loggers_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "content"
    t.boolean "resolved", default: false
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "question_hashid"
    t.index ["question_id"], name: "index_feedbacks_on_question_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "alt_text"
    t.bigint "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_images_on_question_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_keywords_on_name", unique: true
  end

  create_table "keywords_questions", id: false, force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "keyword_id", null: false
    t.index ["keyword_id", "question_id"], name: "index_keywords_questions_on_keyword_id_and_question_id"
    t.index ["question_id", "keyword_id"], name: "index_keywords_questions_on_question_id_and_keyword_id", unique: true
  end

  create_table "question_aggregations", force: :cascade do |t|
    t.integer "parent_question_id", null: false
    t.string "parent_question_type", null: false
    t.integer "child_question_id", null: false
    t.string "child_question_type", null: false
    t.integer "presentation_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_question_id", "child_question_id", "presentation_order"], name: "question_aggregations_parent_child_idx", unique: true
    t.index ["presentation_order"], name: "index_question_aggregations_on_presentation_order"
  end

  create_table "questions", force: :cascade do |t|
    t.text "text"
    t.string "type", null: false
    t.boolean "child_of_aggregation", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "data"
    t.string "level"
    t.tsvector "searchable"
    t.bigint "user_id", null: false
    t.index ["searchable"], name: "index_questions_on_searchable", using: :gin
    t.index ["type"], name: "index_questions_on_type"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "questions_subjects", id: false, force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "question_id", null: false
    t.index ["question_id", "subject_id"], name: "index_questions_subjects_on_question_id_and_subject_id", unique: true
    t.index ["subject_id", "question_id"], name: "index_questions_subjects_on_subject_id_and_question_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subjects_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.boolean "admin", default: false, null: false
    t.boolean "active", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "questions"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "export_loggers", "questions"
  add_foreign_key "export_loggers", "users"
  add_foreign_key "feedbacks", "questions"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "images", "questions"
  add_foreign_key "questions", "users"
end
