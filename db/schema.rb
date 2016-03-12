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

ActiveRecord::Schema.define(version: 20160312000254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "steamid",    null: false
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "link"
    t.string   "image"
    t.string   "info"
  end

  add_index "games", ["steamid"], name: "index_games_on_steamid", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "steamid",    limit: 8,                null: false
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "enabled",              default: true
  end

  add_index "groups", ["steamid"], name: "index_groups_on_steamid", unique: true, using: :btree

  create_table "hosts", force: :cascade do |t|
    t.string   "address"
    t.string   "ip"
    t.integer  "port"
    t.integer  "query_port"
    t.string   "name"
    t.string   "map"
    t.integer  "current"
    t.integer  "max"
    t.boolean  "password"
    t.integer  "users_count"
    t.boolean  "respond",                         default: true
    t.boolean  "auto_update",                     default: true
    t.boolean  "banned",                          default: false
    t.boolean  "updated",                         default: false
    t.boolean  "visible",                         default: false
    t.boolean  "refresh",                         default: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.datetime "last_successful_query",           default: '1970-01-01 00:00:00', null: false
    t.boolean  "tried_query",                     default: false
    t.integer  "lobby",                 limit: 8
    t.text     "flags"
    t.string   "link"
    t.string   "players"
    t.integer  "game_id"
    t.integer  "network_id"
  end

  add_index "hosts", ["game_id"], name: "index_hosts_on_game_id", using: :btree
  add_index "hosts", ["network_id"], name: "index_hosts_on_network_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message"
    t.string   "message_type"
    t.boolean  "show",         default: true
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "networks", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "cidr",       null: false
  end

  create_table "seats", force: :cascade do |t|
    t.string   "seat",                      null: false
    t.string   "clan"
    t.string   "handle"
    t.boolean  "updated",    default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "year"
  end

  create_table "seats_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "seat_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "steamid",     limit: 8,                 null: false
    t.string   "name"
    t.string   "url"
    t.string   "avatar"
    t.boolean  "admin",                 default: false
    t.boolean  "auto_update",           default: true
    t.boolean  "display",               default: true
    t.boolean  "banned",                default: false
    t.boolean  "updated",               default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "host_id"
  end

  add_index "users", ["host_id"], name: "index_users_on_host_id", using: :btree
  add_index "users", ["steamid"], name: "index_users_on_steamid", unique: true, using: :btree

  add_foreign_key "hosts", "games"
  add_foreign_key "hosts", "networks"
  add_foreign_key "users", "hosts"
end
