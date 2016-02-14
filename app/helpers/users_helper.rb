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
  	if user.seat_id.blank?
  		return user.name
  	else
      return "[#{user.seat.seat}] #{user.seat.clan} #{user.seat.handle}"
  	end
  end  
end
