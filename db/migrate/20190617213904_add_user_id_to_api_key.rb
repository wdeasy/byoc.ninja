class AddUserIdToApiKey < ActiveRecord::Migration[5.2]
  def up
		add_column :api_keys, :user_id, :integer
  end
  def down
  	remove_column :api_keys, :user_id
  end
end
