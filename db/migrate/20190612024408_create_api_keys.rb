class CreateApiKeys < ActiveRecord::Migration[5.2]
  def up
    create_table :api_keys do |t|
      t.string :access_token

      t.timestamps
    end
  end

  def down
    drop_table :api_keys
  end
end
