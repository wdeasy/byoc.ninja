module Name
  def Name.decolor_name(name)
    if name
      name.gsub!(/\^[0-8]/,'')
    end

    return name
  end

  def Name.color_name(name)
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

  def Name.clean_url(url)
    unless url.nil?
      url.slice! "javascript:"
      url.slice! "data:"
      url
    end
  end

  def Name.display_name(name)
    length = name.scan(/\^[1-8]/).count*2+40
    return name[0..length]
  end

  def Name.clean_name(name)
    unless name.nil?
      if !name.valid_encoding?
        name = name.encode("UTF-16be", :invalid=>:replace, :replace=>"").encode('UTF-8')
      end

      name.strip!
      name = name.gsub(/[^[:print:]]/i, '')
      name = name.gsub(/(<color[^>]*>)|(<\/color>)/,'')

      name = decolor_name(name)
    end

    return name
  end
end
