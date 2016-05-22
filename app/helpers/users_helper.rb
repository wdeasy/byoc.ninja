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
        name = "[#{user.seats.first.seat}] #{user.seats.first.handle}"
      end
    end    

    length = name.scan(/\^[1-8]/).count*2+25
    return name[0..length]
  end

  def color_name(name)
    name = sanitize(name)
    if name
      carets = name.scan(/\^[1-8]/).count
      if carets > 0
        name.gsub!("^1","<font color=\"red\">") 
        name.gsub!("^2","<font color=\"green\">")
        name.gsub!("^3","<font color=\"yellow\">")
        name.gsub!("^4","<font color=\"blue\">")
        name.gsub!("^5","<font color=\"lightblue\">")
        name.gsub!("^6","<font color=\"magent\">")
        name.gsub!("^7","<font color=\"black\">")
        name.gsub!("^8","<font color=\"black\">")

        for i in 0..carets
          pos = (name.rindex("'s Lobby") ? name.rindex("'s Lobby") : -1)
          name.insert(pos,"</font>")
        end
      end        
    end

    return sanitize name, :tags => %w(font), :attributes => %w(color)
  end

  def decolor_name(name)
    if name
      name.gsub!("^1","") 
      name.gsub!("^2","")
      name.gsub!("^3","")
      name.gsub!("^4","")
      name.gsub!("^5","")
      name.gsub!("^6","")
      name.gsub!("^7","")
      name.gsub!("^8","") 
    end

    return name
  end  
end
