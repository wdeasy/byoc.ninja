class ChangeMessagesToEnum < ActiveRecord::Migration[6.0]
  def up
    Message.update_all("message_type='0'")
    change_column :messages, :message_type, :integer, using: 'message_type::integer'
    change_column :messages, :message_type, :integer, :default => 0, :null => false
  end

  def down
    change_column :messages, :message_type, :integer, :default => nil
    change_column :messages, :message_type, :string
    Message.update_all("message_type='success'")
  end
end
