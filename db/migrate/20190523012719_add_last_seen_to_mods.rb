class AddLastSeenToMods < ActiveRecord::Migration[5.2]
  def up
    add_column :mods, :last_seen, :datetime
    remove_column :mods, :dir
    remove_column :mods, :info
    remove_column :games, :info
  end
  def down
  	remove_column :mods, :last_seen
    add_column :mods, :dir, :string
    add_column :mods, :info, :string
    add_column :games, :info, :string
  end
end
