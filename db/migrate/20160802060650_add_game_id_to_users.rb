class AddGameIdToUsers < ActiveRecord::Migration
  def up
		add_column :users, :game_id, :integer
		add_column :games, :supported, :boolean, :null => false, :default => :true		
  end
  def down
  	remove_column :users, :game_id
  	remove_column :games, :supported  	
  end
end
