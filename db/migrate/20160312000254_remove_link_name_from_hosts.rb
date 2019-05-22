class RemoveLinkNameFromHosts < ActiveRecord::Migration[5.2]
  def up
    remove_column :hosts, :link_name
    add_column :games, :info, :string

    rename_column :hosts, :join_link, :link
    rename_column :games, :store_link, :link
    rename_column :games, :full_img, :image
    remove_column :games, :comm_link
  end

  def down
  	add_column :hosts, :link_name, :string
  	remove_column :games, :info

    rename_column :hosts, :link, :join_link
    rename_column :games, :link, :store_link
    rename_column :games, :image, :full_img
  	add_column :games, :comm_link, :string
  end
end
