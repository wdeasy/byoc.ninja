class ChangeIdentitiesToEnum < ActiveRecord::Migration[6.0]
  def up
    Identity.where("provider = 'steam'").update_all("provider = '0'")
    Identity.where("provider = 'discord'").update_all("provider = '1'")

    change_column :identities, :provider, :integer, using: 'provider::integer'

		add_column :identities, :name, :string
		add_column :identities, :avatar, :string
		add_column :identities, :url, :string
  end

  def down
    change_column :identities, :provider, :string

    Identity.where("provider = '0'").update_all("provider = 'steam'")
    Identity.where("provider = '1'").update_all("provider = 'discord'")

    remove_column :identities, :name
    remove_column :identities, :avatar
    remove_column :identities, :url
  end
end
