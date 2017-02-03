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

ActiveRecord::Schema.define(version: 20170203194802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "authors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "links_count", default: 0, null: false
    t.string   "slug"
    t.index ["slug"], name: "index_authors_on_slug", unique: true, using: :btree
  end

  create_table "clicks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "link_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_clicks_on_link_id", using: :btree
    t.index ["user_id"], name: "index_clicks_on_user_id", using: :btree
  end

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "link_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_favorites_on_link_id", using: :btree
    t.index ["user_id"], name: "index_favorites_on_user_id", using: :btree
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "title",                       null: false
    t.string   "url",                         null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "slug"
    t.integer  "links_count",     default: 0, null: false
    t.datetime "last_fetched_at"
    t.index ["slug"], name: "index_feeds_on_slug", unique: true, using: :btree
    t.index ["title"], name: "index_feeds_on_title", unique: true, using: :btree
    t.index ["url"], name: "index_feeds_on_url", unique: true, using: :btree
  end

  create_table "impressions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "link_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_impressions_on_link_id", using: :btree
    t.index ["user_id"], name: "index_impressions_on_user_id", using: :btree
  end

  create_table "links", force: :cascade do |t|
    t.citext   "title",                             null: false
    t.string   "url",                               null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "feed_id"
    t.citext   "body"
    t.datetime "published_at"
    t.integer  "clicks_count",      default: 0,     null: false
    t.integer  "shares_count",      default: 0,     null: false
    t.integer  "author_id"
    t.string   "guid"
    t.integer  "favorites_count",   default: 0,     null: false
    t.integer  "impressions_count", default: 0,     null: false
    t.boolean  "indexing",          default: false, null: false
    t.index ["clicks_count"], name: "index_links_on_clicks_count", using: :btree
    t.index ["feed_id"], name: "index_links_on_feed_id", using: :btree
    t.index ["published_at"], name: "index_links_on_published_at", using: :btree
    t.index ["shares_count"], name: "index_links_on_shares_count", using: :btree
    t.index ["url"], name: "index_links_on_url", unique: true, using: :btree
  end

  create_table "shares", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "link_id"
    t.string   "network"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_shares_on_link_id", using: :btree
    t.index ["user_id"], name: "index_shares_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  add_foreign_key "clicks", "links"
  add_foreign_key "clicks", "users"
  add_foreign_key "favorites", "links"
  add_foreign_key "favorites", "users"
  add_foreign_key "impressions", "links"
  add_foreign_key "impressions", "users"
  add_foreign_key "links", "feeds"
  add_foreign_key "shares", "links"
  add_foreign_key "shares", "users"
end
