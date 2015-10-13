class DropLobbiesTable < ActiveRecord::Migration
  def up
  	add_column :servers, :lobbysteamid, :integer, :limit => 8
  	remove_column :users, :lobbysteamid
  	drop_table :lobbies
  end

  def down
 		remove_column :servers, :lobbysteamid
 		add_column :users, :lobbysteamid, :integer, :limit => 8
    create_table :lobbies, id: false do |z|
      z.integer :lobbysteamid, :limit => 8, null: false
      z.string  :gameserverip
      z.boolean :updated, :default => false

      z.timestamps null: false
    end

    add_index :lobbies, :lobbysteamid, unique: true
  end
end
