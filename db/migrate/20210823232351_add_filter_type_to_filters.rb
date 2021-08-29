class AddFilterTypeToFilters < ActiveRecord::Migration[6.1]
  def up
    add_column :filters, :filter_type, :integer, :default => 1, :null => false
  end

  def down
    remove_column :filters, :filter_type
  end
end
