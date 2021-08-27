class UniqueFilterNames < ActiveRecord::Migration[6.1]
  def up
    change_column :filters, :name, :string, :null => false, :unique => true
  end

  def down
    change_column :filters, :name, :string, :null => true, :unique => false
  end
end
