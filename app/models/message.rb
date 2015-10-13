class Message < ActiveRecord::Base
  def Message.display
    m = select("message, message_type").where(show: true).last
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