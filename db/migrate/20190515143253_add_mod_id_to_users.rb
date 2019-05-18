class AddModIdToUsers < ActiveRecord::Migration[5.2]
  def up
		add_column :users, :mod_id, :integer
    add_column :hosts, :mod_id, :integer
  end
  def down
  	remove_column :users, :mod_id
    remove_column :hosts, :mod_id
  end
end
