class AddUsersSeatsTable < ActiveRecord::Migration[5.2]
  def up
  	create_join_table :users, :seats
    remove_column :users, :seat_id
    change_column :hosts, :flags, :text
  end

  def down
  	drop_table :users_seats
  	add_column :users, :seat_id, :integer
    change_column :hosts, :flags, :string
  end
end
