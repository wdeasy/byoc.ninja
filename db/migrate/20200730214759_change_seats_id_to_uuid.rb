class ChangeSeatsIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :seats, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :users, :seat_uuid, :uuid

    execute <<-SQL
      UPDATE users SET seat_uuid = seats.uuid
      FROM seats WHERE users.seat_id = seats.id;
    SQL

    change_table :users do |t|
      t.remove :seat_id
      t.rename :seat_uuid, :seat_id
    end

    change_table :seats do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE seats ADD PRIMARY KEY (id);"
  end
end
