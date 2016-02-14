class RemoveNotNullFromHostAddresses < ActiveRecord::Migration
  def up
  	change_column_null :hosts, :address, true, nil
  end

  def down
  end
end
