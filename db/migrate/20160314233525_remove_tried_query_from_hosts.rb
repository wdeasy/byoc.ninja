class RemoveTriedQueryFromHosts < ActiveRecord::Migration[5.2]
  def up
    remove_column :hosts, :tried_query
  end

  def down
  	add_column :hosts, :tried_query, :boolean, :default => false
  end
end
