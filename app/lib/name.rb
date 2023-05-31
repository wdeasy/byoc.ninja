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
    unless url.present?
      return nil
    end

    url.slice! "javascript:"
    url.slice! "data:"

    return valid_url(url)
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


  def Name.valid_url(url)
    unless url.present?
      return nil
    end

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    if url.start_with?("https://")
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    request = Net::HTTP::Get.new(uri.request_uri)

    begin
      response = http.request(request)
    rescue => e
      logger.info "Unable to update Discord connections"
      logger.info e.message
    end

    if response.code == "404"
      nil
    else
      url
    end
  end

  def Name.get_clan(username)
    return nil if username.blank?

    h = clean_name(username)
    if h.match(/^\[.*\S.*\].*\S.*$/)
      h.split(/[\[\]]/)[1].strip
    else
      nil
    end
  end

  def Name.get_handle(username)
    return nil if username.blank?

    handle = clean_name(username)
    handle = handle.index('#').nil? ? handle : handle[0..(handle.rindex('#')-1)]

    if handle.match(/^\[.*\S.*\].*\S.*$/)
      handle = handle.split(/[\[\]]/)[-1].strip
    end

    return handle
  end  
end
