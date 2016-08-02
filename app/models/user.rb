class User < ActiveRecord::Base
  require 'open-uri'

  belongs_to :host, counter_cache: true
  has_and_belongs_to_many :seats
  belongs_to :game 

  def User.update(player, host_id, game_id)

    user = User.find_by_steamid(player["steamid"])

    if user.auto_update == true
      user.update_attributes(
        :name => player["personaname"],
        :url => player["profileurl"],
        :avatar => player["avatar"],
        :host_id => host_id,
        :game_id => game_id,
        :updated => true
      )
    else
      user.update_attributes(
        :host_id => host_id,
        :updated => true
      )  
    end  

    if host_id != nil
      Host.reset_counters(host_id, :users)
    end     
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
        User.fill(steamid)
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

  def User.fill(steamid)
    string = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_WEB_API_KEY']}&steamids=#{steamid}"

    begin
      parsed = JSON.parse(open(string).read)
    rescue => e
      puts "JSON failed to parse #{string}"
    end

    if parsed != nil
      parsed["response"]["players"].each do |player|
        User.update(player, nil, nil)
      end
    end
  end
end