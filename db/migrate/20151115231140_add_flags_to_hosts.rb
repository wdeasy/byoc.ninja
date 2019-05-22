class AddFlagsToHosts < ActiveRecord::Migration[5.2]
  def up
  	add_column :hosts, :flags, :string
  	add_column :games, :store_link, :string
  	add_column :games, :comm_link, :string
  	add_column :games, :full_img, :string
  end

  def down
 		remove_column :hosts, :flags
 		remove_column :games, :store_link, :string
 		remove_column :games, :comm_link, :string
 		remove_column :games, :full_img, :string
  end
end
