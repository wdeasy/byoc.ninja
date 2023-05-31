class AddHandleToIdentities < ActiveRecord::Migration[7.0]
  def up
    add_column :identities, :clan, :string
    add_column :identities, :handle, :string

  end

  def down
    remove_column :identities, :clan
    remove_column :identities, :handle
  end
end
