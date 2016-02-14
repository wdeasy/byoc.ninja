class AddPrimaryKeyToHosts < ActiveRecord::Migration
  def up
    remove_column :hosts, :network
  	add_column :hosts, :id, :primary_key
    add_column :users, :id, :primary_key
    add_column :games, :id, :primary_key
    add_column :groups, :id, :primary_key
    add_column :seats, :id, :primary_key
    remove_column :users, :seat
    remove_index :seats, :seat
    remove_column :hosts, :gameid
  	remove_index :hosts, :address
  	remove_column :users, :address
    remove_column :hosts, :slug
    add_column :seats, :year, :int
    add_column :networks, :cidr, :string, null: false
    remove_column :networks, :min
    remove_column :networks, :max
    rename_column :networks, :network, :name


    rename_column :games, :gameid, :steamid
    rename_column :groups, :groupid64, :steamid 
  end

  def down
  	remove_column :hosts, :id
    remove_column :users, :idS
    remove_column :games, :id
    remove_column :groups, :id
    remove_column :seats, :id
    add_column :users, :seat, :string
    add_index :seats, :seat, unique: true
    add_column :hosts, :gameid , :string
  	add_index :hosts, :address, unique: true
  	add_column :users, :address, :string
    add_column :hosts, :slug, :string
    remove_column :seats, :year
    remove_column :networks, :cidr
    add_column :networks, :min
    add_column :networks, :max
    add_column :hosts, :network, :string
    rename_column :networks, :name, :network    

    rename_column :games, :steamid, :gameid
    rename_column :groups, :steamid, :groupid64
  end
end
