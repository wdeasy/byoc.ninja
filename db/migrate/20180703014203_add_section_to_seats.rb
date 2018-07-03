class AddSectionToSeats < ActiveRecord::Migration[5.2]
  def up
    add_column :seats, :section, :integer
    add_column :seats, :row, :string
    add_column :seats, :number, :integer
    add_column :seats, :sort, :string
  end
  def down
  	remove_column :seats, :section
    remove_column :seats, :row
    remove_column :seats, :number
    remove_column :seats, :sort
  end
end
