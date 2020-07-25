module UsersHelper
  def display_avatar(user, options={})
    size = "_full.jpg"
    #size = "_medium.jpg"
    avatar = ''
    if !user.avatar.nil?
  	   avatar = user.avatar.gsub(".jpg", size)
    elsif !user.discord_avatar.nil?
       avatar = user.discord_avatar
    end

    avatar.blank? ? avatar : (image_tag avatar, options)
  end

  def display_name(user)
    name = user.handle

    if user.seat.present?
      name.prepend("[#{user.seat.seat}] ")
    end

    length = name.scan(/\^[1-8]/).count*2+40
    return decolor_name(name[0..length])
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

  def slice_url(url)
    url.slice! "javascript:"
    url.slice! "data:"
    url
  end
end
