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

ActiveRecord::Schema.define(version: 20141217200112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.string   "remote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_domains", force: true do |t|
    t.integer  "category_id"
    t.integer  "domain_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_domains", ["category_id", "domain_id"], name: "index_category_domains_on_category_id_and_domain_id", unique: true, using: :btree
  add_index "category_domains", ["category_id"], name: "index_category_domains_on_category_id", using: :btree
  add_index "category_domains", ["domain_id"], name: "index_category_domains_on_domain_id", using: :btree

  create_table "domains", force: true do |t|
    t.string   "name"
    t.string   "tld"
    t.string   "listing_url"
    t.decimal  "price",       precision: 8, scale: 2
    t.datetime "closing_on"
    t.datetime "listed_on"
    t.datetime "expires_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                              default: false, null: false
    t.string   "remote_user"
  end

end
