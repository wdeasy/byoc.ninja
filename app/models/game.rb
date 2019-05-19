class Game < ApplicationRecord
  require 'open-uri'

  has_many :hosts
  has_many :mods
  has_many :users

  def Game.update(appid, info, supported, profile=nil)
    game = Game.where(appid: appid).first_or_create do |game|
      url = "https://store.steampowered.com/api/appdetails/?appids=#{appid}"

      begin
        parsed = JSON.parse(open(url).read)
      rescue => e
        puts "JSON failed to parse #{url}"
      end

      name = nil
      link = nil
      image = nil

      unless parsed.blank?
        if parsed["#{appid}"]['success']
          name = parsed["#{appid}"]['data']['name']
          image = parsed["#{appid}"]['data']['header_image']
          link = valid_link("https://store.steampowered.com/app/#{appid}")
        end
      end

      if name.nil? && !profile.nil?
        name = name_from_profile(profile)
      end

      game.name = name.blank? ? Host.valid_name(info) : Host.valid_name(name)
      game.info = info
      game.link = link
      game.image = image
      game.source = "auto"
      game.supported = supported
    end

    if supported == true && game.supported == false
      game.update_attributes(
        :supported => true
      )
    end

    return game.id
  end

  def self.valid_link(url)
    page = lookup(url)

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
    url = "http://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=#{ENV['STEAM_WEB_API_KEY']}&appid=#{appid}"

    begin
      parsed = JSON.parse(open(url).read)
    rescue => e
      puts "JSON failed to parse #{url}"
    end

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
    page = lookup(url)

    if !page.blank?
      name = page.css('div.profile_in_game_name').text
    end

    return name
  end

  def self.lookup(url)
    page = nil

    begin
      html = open(url)
      page = Nokogiri::HTML(html.read)
    rescue => e
      puts "Nokogiri failed to open HTML #{url}"
    end

    return page
  end

  def Game.update_games
    puts "Updating #{Game.all.count} games."

    Game.all.each do |game|
      puts "Updating #{game.appid}: #{game.name}"

      url = "https://store.steampowered.com/api/appdetails/?appids=#{game.appid}"

      begin
        parsed = JSON.parse(open(url).read)
      rescue => e
        puts "JSON failed to parse #{url}"
        x = 1
      end

      name = Game.name
      link = nil
      image = nil

      unless parsed.blank?
        if parsed["#{game.appid}"]['success']
          name  = Host.valid_name(parsed["#{game.appid}"]['data']['name'])
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

      sleep 41
    end
  end
end
