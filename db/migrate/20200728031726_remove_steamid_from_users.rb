class RemoveSteamidFromUsers < ActiveRecord::Migration[6.0]
  def up
    remove_index :users, name: "index_users_on_steamid"
    remove_column :users, :steamid
  end

  def down
    add_column :users, :steamid, :bigint
    add_index :users, :steamid, unique: true
  end
end
