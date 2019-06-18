class AddYesterdayToSteamWebApi < ActiveRecord::Migration[5.2]
  def up
		add_column :steam_web_apis, :yesterday, :integer
  end
  def down
  	remove_column :steam_web_apis, :yesterday
  end
end
