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

ActiveRecord::Schema[7.0].define(version: 2021_08_24_045303) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "filters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "filter_type", default: 0, null: false
  end

  create_table "games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "appid"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "image"
    t.boolean "joinable", default: true
    t.integer "source", default: 0, null: false
    t.boolean "queryable", default: false, null: false
    t.boolean "multiplayer", default: true, null: false
    t.datetime "last_seen"
    t.index ["appid"], name: "index_games_on_appid", unique: true
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "steamid", null: false
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: false
    t.index ["steamid"], name: "index_groups_on_steamid", unique: true
  end

  create_table "hosts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.string "ip"
    t.integer "port"
    t.integer "query_port"
    t.string "name"
    t.string "map"
    t.integer "current"
    t.integer "max"
    t.boolean "password"
    t.integer "users_count"
    t.boolean "respond", default: true
    t.boolean "auto_update", default: true
    t.boolean "banned", default: false
    t.boolean "updated", default: false
    t.boolean "visible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_successful_query", default: "1969-12-31 18:00:00", null: false
    t.bigint "lobby"
    t.text "flags"
    t.string "url"
    t.string "players"
    t.integer "source", default: 0, null: false
    t.bigint "steamid"
    t.boolean "pin", default: false
    t.boolean "lan"
    t.uuid "game_id"
    t.uuid "mod_id"
    t.uuid "network_id"
    t.index ["game_id"], name: "index_hosts_on_game_id"
    t.index ["mod_id"], name: "index_hosts_on_mod_id"
    t.index ["network_id"], name: "index_hosts_on_network_id"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uid", null: false
    t.integer "provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "avatar"
    t.string "url"
    t.boolean "enabled"
    t.uuid "user_id"
    t.boolean "banned", default: false, null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "message"
    t.integer "message_type", default: 0, null: false
    t.boolean "show", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "steamid"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_seen"
    t.uuid "game_id"
    t.index ["game_id"], name: "index_mods_on_game_id"
  end

  create_table "networks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "name", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cidr", null: false
  end

  create_table "seats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "seat", null: false
    t.string "clan"
    t.string "handle"
    t.boolean "updated", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section"
    t.string "row"
    t.string "number"
    t.string "sort"
  end

  create_table "steam_web_apis", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key"
    t.integer "calls", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "yesterday"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "admin", default: false
    t.boolean "auto_update", default: true
    t.boolean "display", default: true
    t.boolean "banned", default: false
    t.boolean "updated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seat_count", default: 0
    t.string "clan"
    t.string "handle"
    t.uuid "host_id"
    t.uuid "game_id"
    t.uuid "mod_id"
    t.uuid "seat_id"
    t.index ["game_id"], name: "index_users_on_game_id"
    t.index ["host_id"], name: "index_users_on_host_id"
    t.index ["seat_id"], name: "index_users_on_seat_id"
  end

end
