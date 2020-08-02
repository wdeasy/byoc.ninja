class AddBannedToIdentities < ActiveRecord::Migration[6.0]
  def up
		add_column :identities, :banned, :boolean, :null => false, :default => :false
  end
  def down
    remove_column :identities, :banned
  end
end
