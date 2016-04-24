class AddSteamidToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :steamid, :string 
    remove_column :hosts, :refresh      
  end

  def down
  	remove_column :hosts, :steamid
  	add_column :hosts, :refresh, :boolean, :default => false
  end
end
