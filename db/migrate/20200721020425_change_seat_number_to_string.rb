class ChangeSeatNumberToString < ActiveRecord::Migration[6.0]
  def up
    change_column :seats, :number, :string
  end
  def down
  	change_column :seats, :number, :integer
  end
end
