class AddSourceToHosts < ActiveRecord::Migration[5.2]
  def up
		add_column :hosts, :source, :string

		change_column :games, :steamid, :string, :null => false, :unique => true
		change_column :groups, :steamid, :integer, limit: 8, :null => false, :unique => true
		change_column :users, :steamid, :integer, limit: 8, :null => false, :unique => true

		remove_column :hosts, :steamid
		add_column :hosts, :steamid, :integer, limit: 8, :unique => true
  end
  def down
  	remove_column :hosts, :source

		change_column :games, :steamid, :string, :null => false
		change_column :groups, :steamid, :integer, limit: 8, :null => false
		change_column :users, :steamid, :integer, limit: 8, :null => false

		remove column :hosts, :steamid
		add_column :hosts, :steamid, :string
  end
end
