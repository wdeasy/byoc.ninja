class AddHostLinks < ActiveRecord::Migration[5.2]
  def up
  	#add join link
  	add_column :hosts, :join_link, :string
  	add_column :hosts, :link_name, :string
  	add_column :hosts, :players, :string

  	#rename stuff
  	rename_column :users, :profileurl, :url
  	rename_column :users, :personaname, :name
  	rename_column :users, :gameserverip, :address
  	rename_column :hosts, :gameserverip, :address
  	rename_column :hosts, :lobbysteamid, :lobby
  	rename_column :games, :gameextrainfo, :name
  end

  def down
  	remove_column :hosts, :join_link
  	remove_column :hosts, :link_name
  	remove_column :hosts, :players

  	rename_column :users, :url, :profileurl
  	rename_column :users, :name, :personaname
		rename_column :users, :address, :gameserverip
  	rename_column :hosts, :address, :gameserverip
  	rename_column :hosts, :lobby, :lobbysteamid
  	rename_column :games, :name, :gameextrainfo

  end
end
