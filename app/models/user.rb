class User < ApplicationRecord
  require 'open-uri'

  belongs_to :host, counter_cache: true, optional: true
  belongs_to :seat, optional:true
  belongs_to :game, optional: true
  belongs_to :mod, optional: true
  has_many :api_keys
  has_many :identities

  def self.create_with_omniauth(auth)
    user = nil
    if auth['provider'] == 'steam'
      user = User.where(steamid: auth.uid).first_or_create
    elsif auth['provider'] == 'discord'
      user = User.where(discord_uid: auth.uid).first_or_create
    end

    return user
  end

  def self.update_with_omniauth(user_id, auth)
    user = find_by(id: user_id)
    if auth['provider'] == 'steam'
      user.update_attributes(
        :steamid => auth.uid,
     	  :name	   => auth.info['nickname'],
    	  :url 	   => auth.extra['raw_info']['profileurl'],
    	  :avatar  => auth.extra['raw_info']['avatar']
    	)
    elsif auth['provider'] == 'discord'
      user.update_attributes(
        :discord_uid      => auth.uid,
        :discord_username => "#{auth.extra['raw_info']['username']}\##{auth.extra['raw_info']['discriminator']}",
    	  :discord_avatar   => auth.info['image']
    	)
    end
  end

  def User.update(player, host_id, game_id, mod_id=nil)

    user = User.find_by_steamid(player["steamid"])

    if user.auto_update == true
      user.update_attributes(
        :name => player["personaname"],
        :url => player["profileurl"],
        :avatar => player["avatar"],
        :host_id => host_id,
        :game_id => game_id,
        :mod_id => mod_id,
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

      url.prepend("https://")

      if url.last != "/"
        url << "/"
      end
    end
    return url
  end

  def User.steamid_from_url(url)
    begin
      url = url_cleanup(url)
      html = URI.open("#{url}?xml=1")
      doc = Nokogiri::XML(html)

      return doc.at_css("steamID64").text
    rescue => e
      return nil
    end
  end

  def User.search_summary_for_seat(steamid, seat)
    begin
      url = "https://steamcommunity.com/profiles/#{steamid}/"
      html = URI.open(url)
      doc = Nokogiri::HTML(html)

      if doc.css('div.profile_summary')
        if doc.css('div.profile_summary').text.include? seat
          return true
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

  def User.update_seat_from_omniauth(user_id, seat_id)
    success = false
    message = ""

    user = User.find_by(id: user_id)
    if user.nil?
      message = "That user doesn't exist!"
      return {:success => success, :message => message}
    end

    seat = Seat.where(:seat => seat_id).first
    if seat.nil?
      message = "That seat doesn't exist!"
      return {:success => success, :message => message}
    end

    if (user.seat_count > 2 && user.admin == false)
      message = "You're linked to #{seat.seat}!"
      return {:success => true, :message => message}
    else
      success = user.update_attributes(
        :seat_id => seat.id,
        :seat_count => user.seat_count + 1
      )

      if success == true
        message = "You're linked to #{seat.seat}!"
        return {:success => success, :message => message}
      else
        message = "Unable to save your seat."
        return {:success => success, :message => message}
      end
    end
  end

  def User.update_seat(seat_id, url)
    success = false
    message = ""

    if seat_id.nil?
      message = "Please select a seat."
      return {:success => success, :message => message}
    end

    if url.nil?
      message = "Please enter your profile URL"
      return {:success => success, :message => message}
    end

    url = User.url_cleanup(url)
    unless url.start_with?('http://steamcommunity.com/id/','http://steamcommunity.com/profiles/','https://steamcommunity.com/id/','https://steamcommunity.com/profiles/')
      message "Please enter a valid profile URL"
      return {:success => success, :message => message}
    end

    steamid = User.steamid_from_url(url)
    if steamid.nil?
      message = "Could not parse steamid from URL. Please check the url and try again."
      return {:success => success, :message => message}
    end

    seat = Seat.where(:seat => seat_id).first
    if seat.nil?
      message = "Unknown seat."
      return {:success => success, :message => message}
    end

    response = search_summary_for_seat(steamid, seat.seat)
    if response == true
      user = User.lookup(steamid)

      unless (user.seat_count > 2 && user.admin == false)
        user.update_attributes(
          :seat_id => seat.id,
          :seat_count => user.seat_count + 1
        )
        User.fill(steamid)
      end

      success = true
      message =  "You're linked to #{seat.seat}!"
      return {:success => success, :message => message}
    else
      message = response
      return {:success => success, :message => message}
    end
  end

  def User.lookup(steamid)
    user = User.where(steamid: steamid).first_or_create
  end

  def User.fill(steamid)
    parsed = SteamWebApi.get_json(SteamWebApi.get_player_summaries + steamid)

    if parsed != nil
      parsed["response"]["players"].each do |player|
        User.update(player, nil, nil)
      end
    end
  end

  def clan
    unless name.nil?
      if name.match(/^\[.*\S.*\].*\S.*$/)
        name.split(/[\[\]]/)[1].strip
      else
        nil
      end
    end
  end

  def handle
    if name.nil? && !discord_username.nil?
      discord_username[0..(discord_username.rindex('#')-1)]
    else
      if name.match(/^\[.*\S.*\].*\S.*$/)
        name.split(/[\[\]]/)[-1].strip
      else
        name
      end
    end
  end

  def playing
    if mod_id?
      mod.name
    elsif game_id?
      game.name
    else
      nil
    end
  end

end
