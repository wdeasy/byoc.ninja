class AddLanToHosts < ActiveRecord::Migration
  def up
	add_column :hosts, :lan, :boolean	
  end
  def down
  	remove_column :hosts, :lan	
  end
end
