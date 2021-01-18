class Message < ApplicationRecord
  enum message_type: [:success, :info, :warning, :danger]
  validates :message, presence: true

  def self.current(cleared_ids = nil)
    result = where(:show => true)
    result = result.where("id not in (?)", cleared_ids) if cleared_ids.present?
    result
  end

  def Message.clear_all
    message = Message.where(:show => true)
    message.each do |m|
	    m.update(
	      :show	=> false
	    )
    end
    return "Messages cleared."
  end
end
