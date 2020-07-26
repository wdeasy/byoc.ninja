class ChangeNetworksToEnum < ActiveRecord::Migration[6.0]
  def up
    Network.where(:name => 'wan').update_all("name = '0'")
    Network.where(:name => 'private').update_all("name = '1'")
    Network.where(:name => 'byoc').update_all("name = '2'")
    Network.where(:name => 'banned').update_all("name = '3'")

    change_column :networks, :name, :integer, using: 'name::integer'
    change_column :networks, :name, :integer, :default => 0, :null => false
  end

  def down
    change_column :networks, :name, :integer, :default => nil
    change_column :networks, :name, :string

    Network.where(:name => '0').update_all("name = 'wan'")
    Network.where(:name => '1').update_all("name = 'private'")
    Network.where(:name => '2').update_all("name = 'byoc'")
    Network.where(:name => '3').update_all("name = 'banned'")    
  end
end
