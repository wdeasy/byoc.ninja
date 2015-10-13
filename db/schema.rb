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

ActiveRecord::Schema.define(version: 20150701034043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", id: false, force: :cascade do |t|
    t.string   "gameid",        null: false
    t.string   "gameextrainfo"
    t.string   "protocol"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "games", ["gameid"], name: "index_games_on_gameid", unique: true, using: :btree

  create_table "groups", id: false, force: :cascade do |t|
    t.integer  "groupid64",  limit: 8,                null: false
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "enabled",              default: true
  end

  add_index "groups", ["groupid64"], name: "index_groups_on_groupid64", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message"
    t.string   "message_type"
    t.boolean  "show",         default: true
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "networks", force: :cascade do |t|
    t.string   "network"
    t.string   "min"
    t.string   "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocols", force: :cascade do |t|
    t.string   "protocol"
    t.string   "name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "host",       default: "hostname"
    t.string   "map",        default: "map"
    t.string   "num",        default: "num_players"
    t.string   "max",        default: "max_players"
    t.string   "pass",       default: "password"
    t.string   "port",       default: "port"
    t.string   "players",    default: "players"
    t.string   "playername", default: "name"
  end

  add_index "protocols", ["protocol"], name: "index_protocols_on_protocol", unique: true, using: :btree

  create_table "seats", id: false, force: :cascade do |t|
    t.string   "seat",                      null: false
    t.string   "clan"
    t.string   "handle"
    t.boolean  "updated",    default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "seats", ["seat"], name: "index_seats_on_seat", unique: true, using: :btree

  create_table "servers", id: false, force: :cascade do |t|
    t.string   "gameserverip",                                                    null: false
    t.string   "ip"
    t.integer  "port"
    t.integer  "query_port"
    t.string   "gameid"
    t.string   "name"
    t.string   "map"
    t.integer  "current"
    t.integer  "max"
    t.boolean  "password"
    t.integer  "users_count"
    t.string   "network",                         default: "wan"
    t.boolean  "respond",                         default: true
    t.boolean  "auto_update",                     default: true
    t.boolean  "banned",                          default: false
    t.boolean  "updated",                         default: false
    t.boolean  "visible",                         default: false
    t.boolean  "refresh",                         default: false
    t.string   "slug"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.datetime "last_successful_query",           default: '1970-01-01 00:00:00', null: false
    t.boolean  "tried_query",                     default: false
    t.integer  "lobbysteamid",          limit: 8
  end

  add_index "servers", ["gameserverip"], name: "index_servers_on_gameserverip", unique: true, using: :btree

  create_table "users", id: false, force: :cascade do |t|
    t.integer  "steamid",      limit: 8,                 null: false
    t.string   "personaname"
    t.string   "profileurl"
    t.string   "avatar"
    t.string   "gameserverip"
    t.boolean  "admin",                  default: false
    t.boolean  "auto_update",            default: true
    t.boolean  "display",                default: true
    t.boolean  "banned",                 default: false
    t.boolean  "updated",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "seat"
  end

  add_index "users", ["steamid"], name: "index_users_on_steamid", unique: true, using: :btree

end
