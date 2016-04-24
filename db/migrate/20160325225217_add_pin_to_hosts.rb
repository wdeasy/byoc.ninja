class AddPinToHosts < ActiveRecord::Migration
  def up
		add_column :hosts, :pin, :boolean, :default => false

		#remove_column :games, :steamid
		#add_column :games, :steamid, :integer, limit: 8, :null => false, :unique => true
    change_column :games, :steamid, 'integer USING CAST(steamid AS integer)'
    rename_column :games, :steamid, :appid
    add_column :games, :joinable, :boolean, :default => true

    create_table :mods do |b|
      b.string :steamid
      b.string :name
      b.integer :game_id
      b.string :info
      b.string :dir

      b.timestamps null: false
    end				
  end

  def down
  	remove_column :hosts, :pin

		#remove column :games, :steamid
		#add_column :games, :steamid, :string, :null => false
    change_column :games, :steamid, :string
    rename_column :games, :appid, :steamid
    remove_column :games, :joinable

  	drop_table :mods
  end
end
