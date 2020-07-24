class SeatsOneToMany < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :seat_id, :bigint

    drop_table :seats_users
  end

  def down
  	remove_column :users, :seat_id

    create_table :seats_users, id: false, force: :cascade do |t|
      t.bigint :user_id, null: false
      t.bigint :seat_id, null: false
    end
  end
end
