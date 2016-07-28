class User < ActiveRecord::Base
  require 'open-uri'

  belongs_to :host, counter_cache: true
  has_and_belongs_to_many :seats 

  def User.update(player, host_id)

    user = User.find_by_steamid(player["steamid"])

    if user.auto_update == true
      user.update_attributes(
        :name => decolor_name(player["personaname"]),
        :url => player["profileurl"],
        :avatar => player["avatar"],
        :host_id => host_id,
        :updated => true
      )
    else
      user.update_attributes(
        :host_id => host_id,
        :updated => true
      )  
    end  

    Host.reset_counters(host_id, :users)     
  end

  def User.decolor_name(name)
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

  def User.url_cleanup(url)
    if url.include? "steamcommunity.com"
      unless url.start_with? "steamcommunity.com"
        url.slice!(0..(url.index('steamcommunity.com')-1))
      end

      url.prepend("http://")

      if url.last != "/"
        url << "/"
      end
    end
    return url
  end

  def User.steamid_from_url(url)
    begin
      html = open("#{url}?xml=1") 
      doc = Nokogiri::XML(html)

      return doc.at_css("steamID64").text
    rescue => e
      return nil
    end
  end

  def User.search_summary_for_seat(steamid, seat)
    begin
      url = "http://steamcommunity.com/profiles/#{steamid}/"
      html = open(url) 
      doc = Nokogiri::HTML(html)

      if doc.css('div.profile_summary')
        if doc.css('div.profile_summary').text.include? seat
          return "Match"
        else
          return "Could not find #{seat} in your steam profile summary."
        end
      else
        return "Please set your steam profile to public to link your seat."
      end
    rescue => e
      return "Unable to read your steam profile. Please try again."
    end
  end

  def User.update_seat(seat_id, url)
    if seat_id == ""
      return "Please select a seat."
    elsif url == ""
      return "Please enter your profile URL"
    end

    url = User.url_cleanup(url)

    unless url.start_with?('http://steamcommunity.com/id/','http://steamcommunity.com/profiles/')
      return "Please enter a valid profile URL"
    end

    steamid = User.steamid_from_url(url)

    if (steamid != nil)

      s = seat_id.to_i
      seat = Seat.where(:id => s).first.seat

      response = search_summary_for_seat(steamid, seat)
      if response == "Match"
        user = User.lookup(steamid) 
        user.update_attributes(
          :seat_ids => seat_id
        )
        return "You're linked to #{seat}!"
      else
        return response
      end
    else 
      return "Could not parse steamid from URL. Please check the url and try again."
    end
  end

  def User.lookup(steamid)
    user = User.where(steamid: steamid).first_or_create
  end
end