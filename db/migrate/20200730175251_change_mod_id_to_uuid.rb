class ChangeModIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :mods, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :hosts, :mod_uuid, :uuid
    add_column :users, :mod_uuid, :uuid

    execute <<-SQL
      UPDATE hosts SET mod_uuid = mods.uuid
      FROM mods WHERE hosts.mod_id = mods.id;
    SQL

    change_table :hosts do |t|
      t.remove :mod_id
      t.rename :mod_uuid, :mod_id
    end

    execute <<-SQL
      UPDATE users SET mod_uuid = mods.uuid
      FROM mods WHERE users.mod_id = mods.id;
    SQL

    change_table :users do |t|
      t.remove :mod_id
      t.rename :mod_uuid, :mod_id
    end

    change_table :mods do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE mods ADD PRIMARY KEY (id);"
  end
end
