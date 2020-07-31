class ChangeUserIdToUuid < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    add_column :users, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :identities, :user_uuid, :uuid
    add_column :api_keys, :user_uuid, :uuid

    execute <<-SQL
      UPDATE identities SET user_uuid = users.uuid
      FROM users WHERE identities.user_id = users.id;
    SQL

    change_table :identities do |t|
      t.remove :user_id
      t.rename :user_uuid, :user_id
    end

    execute <<-SQL
      UPDATE api_keys SET user_uuid = users.uuid
      FROM users WHERE api_keys.user_id = users.id;
    SQL

    change_table :api_keys do |t|
      t.remove :user_id
      t.rename :user_uuid, :user_id
    end

    change_table :users do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
