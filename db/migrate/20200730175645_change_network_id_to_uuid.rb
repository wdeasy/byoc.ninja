class ChangeNetworkIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :networks, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :hosts, :network_uuid, :uuid

    execute <<-SQL
      UPDATE hosts SET network_uuid = networks.uuid
      FROM networks WHERE hosts.network_id = networks.id;
    SQL

    change_table :hosts do |t|
      t.remove :network_id
      t.rename :network_uuid, :network_id
    end

    change_table :networks do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE networks ADD PRIMARY KEY (id);"
  end
end
