class MoveUserFieldsToIdentity < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :discord_username
    remove_column :users, :discord_uid
    remove_column :users, :discord_avatar
    remove_column :users, :name
    remove_column :users, :url
    remove_column :users, :avatar
  end

  def down
    add_column :users, :discord_username, :string
    add_column :users, :discord_uid, :string
    add_column :users, :discord_avatar, :string
    add_column :users, :name, :string
    add_column :users, :url, :string
    add_column :users, :avatar, :string    
  end
end
