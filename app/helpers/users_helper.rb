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
        name = "[#{user.seats.first.seat}]"
        if !user.seats.first.handle.blank?
          name << " #{user.seats.first.handle}"
        end
      end
    end    

    if name.blank?
      return user.steamid
    else
      length = name.scan(/\^[1-8]/).count*2+25
      return decolor_name(name[0..length])
    end
  end

  def color_name(name)
    name = sanitize(name)
    if name
      carets = name.scan(/\^[1-8]/).count
      if carets > 0
        name.gsub!("^0","<font color=\"black\">")         
        name.gsub!("^1","<font color=\"red\">") 
        name.gsub!("^2","<font color=\"green\">")
        name.gsub!("^3","<font color=\"yellow\">")
        name.gsub!("^4","<font color=\"blue\">")
        name.gsub!("^5","<font color=\"lightblue\">")
        name.gsub!("^6","<font color=\"magent\">")
        name.gsub!("^7","<font color=\"white\">")
        name.gsub!("^8","<font color=\"orange\">")

        for i in 0..carets
          pos = (name.rindex("'s Lobby") ? name.rindex("'s Lobby") : -1)
          name.insert(pos,"</font>")
        end
      end        
    end

    return sanitize name, :tags => %w(font), :attributes => %w(color)
  end 
end
