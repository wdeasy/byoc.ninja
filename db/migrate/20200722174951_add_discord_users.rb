class AddDiscordUsers < ActiveRecord::Migration[6.0]
  def up
    create_table :identities do |u|
      u.string :uid, null: false
      u.string :provider
      u.bigint :user_id

      u.timestamps null: false
    end

		add_column :users, :discord_uid, :string
    add_column :users, :discord_username, :string
    add_column :users, :discord_avatar, :string

    change_column :users, :steamid, :bigint, :null => true
  end

  def down
    drop_table :identities
    change_column :users, :steamid, :bigint, :null => false

  	remove_column :users, :discord_uid
  	remove_column :users, :discord_username
  	remove_column :users, :discord_avatar
  end
end
