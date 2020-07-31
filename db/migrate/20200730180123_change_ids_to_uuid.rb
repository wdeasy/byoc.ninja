class ChangeIdsToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :api_keys, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :filters, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :groups, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :identities, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :messages, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :steam_web_apis, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :api_keys do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE api_keys ADD PRIMARY KEY (id);"

    change_table :filters do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE filters ADD PRIMARY KEY (id);"

    change_table :groups do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE groups ADD PRIMARY KEY (id);"

    change_table :identities do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE identities ADD PRIMARY KEY (id);"

    change_table :messages do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE messages ADD PRIMARY KEY (id);"

    change_table :steam_web_apis do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE steam_web_apis ADD PRIMARY KEY (id);"
  end
end
