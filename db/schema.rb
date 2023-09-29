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

ActiveRecord::Schema[7.0].define(version: 2023_09_27_171851) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["type"], name: "index_questions_on_type"
  end

  create_table "questions_subjects", id: false, force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "subject_id", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
