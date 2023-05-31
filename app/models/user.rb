class User < ApplicationRecord
  include Name
  require 'open-uri'

  belongs_to :host, -> {where(visible: true)}, counter_cache: true, optional: true
  belongs_to :seat, optional:true
  belongs_to :game, optional: true
  belongs_to :mod, optional: true
  has_many :api_keys
  has_many :identities, -> {where(enabled: true).where(banned: false)}

  def as_json(options={})
   super(:only => [:clan, :handle], :methods => [:playing],
      :include => {
        :seat => {:only => [:seat, :section, :row, :number]},
        :host => {:only => [:url]},
        :identities => {:only => [:uid, :provider, :name, :url, :avatar]}
      }
    )
  end

  scope :active, -> { where( banned: false ) }

  def self.create_with_omniauth
    User.create
  end

  def self.update_with_omniauth(user_id, name)
    user = User.find_by(:id => user_id)
    if user.auto_update == true
      clan, handle = get_clan_and_handle(user_id)
      user.update(
        clan: clan,
        handle: handle
      )
    end
  end

  def User.update(player, host_id, game_id, mod_id=nil)
    identity = Identity.find_by(:uid => player["steamid"], :provider => :steam, :enabled => true)
    user = User.find_by(:id => identity.user_id)
    if identity.nil?
      puts "Could not find Identity for #{player["steamid"]}"
      return
    end

    if user.nil?
      puts "Could not find User for #{player["steamid"]}"
      return
    end

    if user.auto_update == false
      user.update(
        :host_id => host_id,
        :updated => true
      )
      return
    end

    unless identity.name == player["personaname"]
      identity.update_attribute(:name, Name.clean_name(player["personaname"]))
    end

    unless identity.url == player["profileurl"]
      identity.update_attribute(:url, Name.clean_url(player["profileurl"]))
    end

    unless identity.avatar == player["avatar"]
      identity.update_attribute(:avatar, Name.clean_url(player["avatar"]))
    end

    user.update(
      :host_id => host_id,
      :game_id => game_id,
      :mod_id => mod_id,
      :updated => true
    )

    clan = identity.clan
    handle = identity.handle

    identity.update(
      :clan => Name.get_clan(player["personaname"]),
      :handle => Name.get_handle(player["personaname"])
    )

    if clan != identity.clan || handle != identity.handle
      clan, handle = get_clan_and_handle(user.id)
      user.update(
        :clan => clan,
        :handle => handle
      )
    end    
  end

  def User.url_cleanup(url)
    return nil unless url.include? "steamcommunity.com"

    unless url.start_with? "steamcommunity.com"
      url.slice!(0..(url.index('steamcommunity.com')-1))
    end

    url.prepend("https://")

    if url.last != "/"
      url << "/"
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

      if doc.css('div.profile_summary').blank?
        return "Please set your steam profile to public to link your seat."
      end

      if doc.css('div.profile_summary').text.include? seat
        return true
      else
        return "Could not find #{seat} in your steam profile summary."
      end
    rescue => e
      return "Unable to read your steam profile. Please try again."
    end
  end

  def User.unlink_seat(user_id)
    success = false
    message = ""

    user = User.find_by(id: user_id)
    if user.nil?
      message = "That user doesn't exist!"
      return {:success => success, :message => message}
    end

    seat = user.seat.seat if user.seat.present?

    success = user.update(
      :seat_id => nil,
      :seat_count => user.seat_count + 1
    )

    Seat.mark_for_update(seat) if seat.present?

    if success == true
      message = "You've unlinked your seat!"
      return {:success => success, :message => message}
    else
      message = "Unable to save your seat."
      return {:success => success, :message => message}
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

    #just for 2020
    taken_seat = User.where(seat_id: seat.id).first
    if !taken_seat.nil? && taken_seat.id != user.id
      message = "That seat is taken!"
      return {:success => success, :message => message}
    end

    if seat == user.seat
      message = "You're linked to #{seat.seat}!"
      return {:success => true, :message => message}
    end

    if (user.banned == true)
      message = "You're linked to #{seat.seat}!"
      return {:success => true, :message => message}
    end

    seats = []
    seats.append(user.seat.seat) if user.seat.present?
    seats.append(seat.seat) if seats.exclude? seat.seat

    success = user.update(
      :seat_id => seat.id,
      :seat_count => user.seat_count + 1
    )

    seats.each do |s|
      Seat.mark_for_update(s)
    end

    if success == true
      message = "You're linked to #{seat.seat}!"
      return {:success => success, :message => message}
    else
      message = "Unable to save your seat."
      return {:success => success, :message => message}
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
    if response == false
      message = response
      return {:success => success, :message => message}
    end

    user = User.lookup(steamid)

    #just for 2020
    taken_seat = User.where(seat_id: seat.id).first
    if !taken_seat.nil? && taken_seat.id != user.id
      message = "That seat is taken!"
      return {:success => success, :message => message}
    end

    if seat == user.seat
      message = "You're linked to #{seat.seat}!"
      return {:success => true, :message => message}
    end

    unless (user.banned == true)
      user.update(
        :seat_id => seat.id,
        :seat_count => user.seat_count + 1
      )
      User.fill(steamid)
    end

    success = true
    message =  "You're linked to #{seat.seat}!"
    return {:success => success, :message => message}
  end

  def User.lookup(steamid)
    identity = Identity.find_by(uid: steamid, provider: :steam)
    if identity.nil?
      identity = Identity.create(uid: steamid, provider: :steam, enabled: true)
    end

    if identity.user_id.nil?
      user = User.create
      identity.user = user
      identity.save
    end

    return identity.user
  end

  def User.fill(steamid)
    parsed = SteamWebApi.get_json(SteamWebApi.get_player_summaries + steamid)

    if parsed != nil
      parsed["response"]["players"].each do |player|
        User.update(player, nil, nil)
      end
    end
  end

  def User.get_clan_and_handle(user_id)
    clan = nil
    handle = nil

    Identity.where(user_id: user_id, enabled: true).find_each do |identity|
      handle = identity.handle if handle.nil?

      return identity.clan, identity.handle if identity.clan?
    end

    return nil, handle
  end

  def display_handle
    if seat_id.nil?
      handle
    else
      prepend_seat(handle, id, seat_id)
    end
  end

  def prepend_seat(handle, user_id, seat_id)
    return handle if seat_id.blank?

    seat = User.find_by(:id => user_id).seat
    unless seat.nil? || handle.nil?
      handle.prepend("[#{seat.seat}] ")
    end
  end

  def url
    Identity.where(:user_id => id, enabled: true).specific(:steam).url
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
