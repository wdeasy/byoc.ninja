module UsersHelper
  def full_av(user, options={})
  	avatarfull = user.avatar.gsub(".jpg","_full.jpg")
  	image_tag avatarfull, options
  end

  def med_av(user, options={})
  	avatarmed = user.avatar.gsub(".jpg","_medium.jpg")
  	image_tag avatarmed, options
  end

  def display_name(user)
  	if user.seat.blank?
  		return user.personaname
  	else
  		seat = Seat.find_by_seat(user.seat)
  		return "[#{seat.seat}] #{seat.clan} #{seat.handle}"
  	end
  end  
end
