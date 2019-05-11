class ChangeSectionToString < ActiveRecord::Migration[5.2]
  def up
    change_column :seats, :section, :string
  end
  def down
  	change_column :seats, :section, :integer
  end
end
