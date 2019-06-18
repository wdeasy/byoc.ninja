class CreateSteamWebApis < ActiveRecord::Migration[5.2]
  def up
    create_table :steam_web_apis do |t|
      t.string :key
      t.integer :calls, default: 0

      t.timestamps
    end
  end

    def down
      drop_table :steam_web_apis
    end
end
