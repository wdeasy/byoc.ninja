class AddSeatCountToUsers < ActiveRecord::Migration[5.2]
  def up
		add_column :users, :seat_count, :integer, :default => 0
  end
  def down
  	remove_column :users, :seat_count
  end
end
