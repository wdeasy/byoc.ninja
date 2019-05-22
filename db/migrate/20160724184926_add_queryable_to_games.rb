class AddQueryableToGames < ActiveRecord::Migration[5.2]
  def up
		add_column :games, :queryable, :boolean, :default => false, null: false
    change_column :hosts, :source, :string, null: false, :default => 'auto'
  end
  def down
  	remove_column :games, :queryable
    change_column :hosts, :source, :string, null: true, :default => nil
  end
end
