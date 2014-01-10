# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131208034424) do

  create_table "attempts", force: true do |t|
    t.text     "solution"
    t.integer  "user_id"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.text     "content"
    t.integer  "author_id"
    t.integer  "design_problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points",            default: 0
  end

  create_table "hints", force: true do |t|
    t.integer  "code_problem_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mistakes", force: true do |t|
    t.integer  "test_id"
    t.string   "wrong_output"
    t.integer  "hint_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problems", force: true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "difficulty"
    t.text     "question"
    t.integer  "category_id"
    t.integer  "author_id"
    t.text     "solution"
    t.text     "skeleton"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", force: true do |t|
    t.text     "input"
    t.integer  "code_problem_id"
    t.string   "correct_output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "usertype"
    t.string   "username"
    t.string   "password"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.boolean  "upvote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
