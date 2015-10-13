class RemoveQueryPortFromGames < ActiveRecord::Migration
  def up
  	remove_column :games, :query_port
  end

  def down
 		add_column :games, :query_port, :integer
  end
end
