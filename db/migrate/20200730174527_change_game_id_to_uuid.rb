class ChangeGameIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :hosts, :game_uuid, :uuid
    add_column :mods, :game_uuid, :uuid
    add_column :users, :game_uuid, :uuid

    execute <<-SQL
      UPDATE hosts SET game_uuid = games.uuid
      FROM games WHERE hosts.game_id = games.id;
    SQL

    change_table :hosts do |t|
      t.remove :game_id
      t.rename :game_uuid, :game_id
    end

    execute <<-SQL
      UPDATE mods SET game_uuid = games.uuid
      FROM games WHERE mods.game_id = games.id;
    SQL

    change_table :mods do |t|
      t.remove :game_id
      t.rename :game_uuid, :game_id
    end

    execute <<-SQL
      UPDATE users SET game_uuid = games.uuid
      FROM games WHERE users.game_id = games.id;
    SQL

    change_table :users do |t|
      t.remove :game_id
      t.rename :game_uuid, :game_id
    end

    change_table :games do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE games ADD PRIMARY KEY (id);"
  end
end
