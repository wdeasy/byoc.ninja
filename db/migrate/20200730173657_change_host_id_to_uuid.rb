class ChangeHostIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :hosts, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :users, :host_uuid, :uuid

    execute <<-SQL
      UPDATE users SET host_uuid = hosts.uuid
      FROM hosts WHERE users.host_id = hosts.id;
    SQL

    change_table :users do |t|
      t.remove :host_id
      t.rename :host_uuid, :host_id
    end

    change_table :hosts do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE hosts ADD PRIMARY KEY (id);"
  end
end
