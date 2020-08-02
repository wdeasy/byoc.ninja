class ChangeLinkToUrl < ActiveRecord::Migration[6.0]
  def up
    rename_column :games, :link, :url
    rename_column :hosts, :link, :url
  end

  def down
    rename_column :games, :url, :link
    rename_column :hosts, :url, :link      
  end
end
