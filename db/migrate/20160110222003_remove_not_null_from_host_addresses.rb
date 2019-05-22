class RemoveNotNullFromHostAddresses < ActiveRecord::Migration[5.2]
  def up
  	change_column_null :hosts, :address, true, nil
  end

  def down
  end
end
