class Message < ApplicationRecord
  enum message_type: [:success, :info, :warning, :danger]

  def self.current(hidden_ids = nil)
    result = where(:show => true)
    result = result.where("id not in (?)", hidden_ids) if hidden_ids.present?
    result
  end

  def Message.clear_all
    message = Message.where(:show => true)
    message.each do |m|
	    m.update_attributes(
	      :show	=> false
	    )
    end
    return "Messages cleared."
  end
end
