class RemoveTriedQueryFromHosts < ActiveRecord::Migration
  def up
    remove_column :hosts, :tried_query  
  end

  def down
  	add_column :hosts, :tried_query, :boolean, :default => false
  end
end
