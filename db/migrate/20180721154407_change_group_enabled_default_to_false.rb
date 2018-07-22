class ChangeGroupEnabledDefaultToFalse < ActiveRecord::Migration[5.2]
  def up
    change_column :groups, :enabled, :boolean, default: false
  end
  def down
  	change_column :groups, :enabled, :boolean, default: true
  end
end
