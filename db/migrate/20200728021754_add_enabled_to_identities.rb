class AddEnabledToIdentities < ActiveRecord::Migration[6.0]
  def up
    add_column :identities, :enabled, :boolean
    Identity.where("enabled = null").update_all("enabled = true")    
  end

  def down
    remove_column :identities, :enabled
  end
end
