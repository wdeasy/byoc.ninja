class RemoveProtocolsAndRenameServers < ActiveRecord::Migration[5.2]
  def up
  	remove_column :games, :protocol
  	drop_table :protocols
  	rename_table :servers, :hosts
  end

  def down
 		add_column :games, :protocol, :string

    create_table :protocols do |b|
      b.string :protocol
      b.string :name, unique: true
	    b.string :host,       default: "hostname"
	    b.string :map,        default: "map"
	    b.string :num,        default: "num_players"
	    b.string :max,        default: "max_players"
	    b.string :pass,       default: "password"
	    b.string :port,       default: "port"
	    b.string :players,    default: "players"
	    b.string :playername, default: "name"
      b.timestamps null: false
    end

    add_index :protocols, :protocol, unique: true
    rename_table :hosts, :servers
  end
end
