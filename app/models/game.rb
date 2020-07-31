class Game < ApplicationRecord
  include Name

  require 'open-uri'

  has_many :hosts
  has_many :mods
  has_many :users

  scope :active, -> { where( :joinable => true ) }

  enum source: [:auto, :manual]

  def as_json(options={})
   super(:only => [:appid, :name, :image, :link])
  end

  def Game.update(appid, info, multiplayer, profile=nil)
    game = Game.where(appid: appid).first_or_create do |game|
      url = SteamWebApi.get_app_details(appid)

      parsed = SteamWebApi.get_json(url)

      name = nil
      link = nil
      image = nil

      unless parsed.blank?
        if parsed["#{appid}"] && parsed["#{appid}"]['success']
          name = parsed["#{appid}"]['data']['name']
          image = parsed["#{appid}"]['data']['header_image']
          link = valid_link("https://store.steampowered.com/app/#{appid}")
        end
      end

      if name.nil? && !profile.nil?
        name = name_from_profile(profile)
      end

      game.name = name.blank? ? Name.clean_name(info) : Name.clean_name(name)
      game.link        = Name.clean_url(link)
      game.image       = image
      game.source      = :auto
      game.multiplayer = multiplayer
      game.last_seen   = Time.now
    end

    if multiplayer == true && game.multiplayer == false
      game.update_attributes(
        :multiplayer => true
      )
    end

    if game.last_seen.nil? || !game.last_seen.today?
      game.update_attributes(
        :last_seen => Time.now
      )
    end

    return game.id
  end

  def self.valid_link(url)
    page = SteamWebApi.get_html(url)

    if page.blank?
      return nil
    end

    name = page.css('title').text
    if name == "Welcome to Steam"
      return nil
    end

    return url
  end

  def self.name_from_appid(appid)
    name = ''
    url = SteamWebApi.get_schema_for_game(appid)
    parsed = SteamWebApi.get_json(url)

    unless parsed.nil?
      name = parsed['game']['gameName']
    end

    return name
  end

  def Game.appid_from_name(name)
    case name
    when "Source SDK Base 2013 Multiplayer"
      appid = 243750
    when "Source SDK Base 2013 Singleplayer"
      appid = 243730
    when "Source SDK Base 2007"
      appid = 218
    when "Source SDK Base 2006"
      appid = 215
    else
      appid = 0
    end
  end

  def Game.name_from_profile(url)
    name = nil
    page =  SteamWebApi.get_html(url)

    if !page.blank?
      name = page.css('div.profile_in_game_name').text
    end

    return name
  end

  def Game.update_game(appid)
    game = Game.where(appid: appid).first

    url = SteamWebApi.get_app_details(game.appid)
    parsed = SteamWebApi.get_json(url)

    name  = game.name
    image = game.image
    link  = game.link

    unless parsed.blank?
      if parsed["#{game.appid}"]['success']
        name  = Name.clean_name(parsed["#{game.appid}"]['data']['name'])
        image = parsed["#{game.appid}"]['data']['header_image']
        link  = valid_link("https://store.steampowered.com/app/#{game.appid}")
      else
        link = nil
        image = nil
      end
    end

    unless game.name == name
      puts "Updating name to #{name}"
    end

    unless game.link == link
      puts "Updating link to #{link}"
    end

    unless game.image == image
      puts "Updating image to #{image}"
    end

    game.update_attributes(
      :name  => name,
      :image => image,
      :link  => link
    )
  end

  def Game.update_games
    appids = []
    Game.all.each do |game|
      appids << game.appid
    end
    puts "Updating #{appids.count} games."

    appids.each do |appid|
      puts "Updating #{appid}"
      update_game(appid)
      sleep 10
    end
  end
end
