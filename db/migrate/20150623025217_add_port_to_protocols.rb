class AddPortToProtocols < ActiveRecord::Migration
  def self.up
  	add_column :protocols, :port, :string, default: 'port'
  	add_column :protocols, :players, :string, default: 'players'
  	add_column :protocols, :playername, :string, default: 'name'
  	add_column :servers, :last_successful_query, :datetime, :null => false, :default => Time.at(0)
  	add_column :servers, :tried_query, :boolean, :default => false
  end
  def self.down
   	remove_column :protocols, :port
   	remove_column :protocols, :players
   	remove_column :protocols, :playername
   	remove_column :servers, :last_successful_query
   	remove_column :servers, :tried_query 	
  end
end
