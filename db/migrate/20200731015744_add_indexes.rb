class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :identities, :user_id
    add_index :api_keys, :user_id

    add_index :users, :host_id

    add_index :hosts, :game_id
    add_index :mods, :game_id
    #add_index :users, :game_id

    add_index :hosts, :mod_id
    add_index :users, :game_id

    add_index :hosts, :network_id

    add_index :users, :seat_id
  end
end
