class AddClanAndHandleToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :clan, :string
    add_column :users, :handle, :string

  end

  def down
    remove_column :users, :clan
    remove_column :users, :handle
  end
end
