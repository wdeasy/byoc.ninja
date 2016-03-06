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
    name = user.name

    user.seats.each do |seat|
      if seat.year == Date.today.year
        name = "[#{user.seats.first.seat}] #{user.seats.first.clan} #{user.seats.first.handle}"
      end
    end    

    return name
  end  
end
