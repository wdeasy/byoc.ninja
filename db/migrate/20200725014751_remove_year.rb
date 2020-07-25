class RemoveYear < ActiveRecord::Migration[6.0]
  def up
    remove_column :seats, :year
  end

  def down
    add_column :seats, :year, :int
  end
end
