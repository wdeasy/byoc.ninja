class ChangeSupportedToMultiplayer < ActiveRecord::Migration[5.2]
  def up
    rename_column :games, :supported, :multiplayer
    add_column :games, :last_seen, :datetime
  end
  def down
  	rename_column :games, :multiplayer, :supported
    remove_column :games, :last_seen
  end
end
