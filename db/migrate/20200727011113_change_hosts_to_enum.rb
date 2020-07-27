class ChangeHostsToEnum < ActiveRecord::Migration[6.0]
  def up
    Host.where("source = 'auto'").update_all("source = '0'")
    Host.where("source = 'manual'").update_all("source = '1'")
    Host.where("source = 'name'").update_all("source = '2'")
    Host.where("source = 'file'").update_all("source = '3'")
    Host.where("source = 'byoc'").update_all("source = '4'")

    change_column :hosts, :source, :string, :default => nil, :null => false
    change_column :hosts, :source, :integer, using: 'source::integer'
    change_column :hosts, :source, :integer, :default => 0, :null => false
    change_column :games, :source, :integer, :default => 0, :null => false
  end

  def down
    change_column :hosts, :source, :integer, :default => nil, :null => false
    change_column :hosts, :source, :string
    change_column :hosts, :source, :string, :default => 'auto', :null => false
    change_column :games, :source, :string, :default => 'auto', :null => false          

    Host.where("source = '0'").update_all("source = 'auto'")
    Host.where("source = '1'").update_all("source = 'manual'")
    Host.where("source = '2'").update_all("source = 'name'")
    Host.where("source = '3'").update_all("source = 'file'")
    Host.where("source = '4'").update_all("source = 'byoc'")
  end
end
