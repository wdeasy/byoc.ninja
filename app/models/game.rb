class Game < ActiveRecord::Base
  require 'open-uri'

  has_many :hosts
  has_many :mods
  has_many :users  

  def Game.update(appid, info, supported)
    game = Game.where(appid: appid).first_or_create do |game|
      name = name_from_appid(appid)

      game.name = name
      game.info = info
      game.source = "auto"
      game.supported = supported

      if name.exclude? "Source SDK"
         game.link = "http://store.steampowered.com/app/#{appid}"
         game.image = "http://cdn.akamai.steamstatic.com/steam/apps/#{appid}/header.jpg"
      end
    end

    if supported == true && game.supported == false
      game.update_attributes(
        :supported => true
      )
    end

    return game.id
  end

  def self.name_from_appid(appid)
    name = ''
    url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/'

    begin
      parsed = JSON.parse(open(url).read)
    rescue => e
      puts "JSON failed to parse #{url}"
    end

    if parsed != nil
      parsed['applist']['apps'].each do |app|
        if appid.to_i == app['appid'].to_i
          name = app['name']
        end
      end       
    end

    return name
  end

  def Game.appid_from_name(name)
    appid = nil
    url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/'

    begin
      parsed = JSON.parse(open(url).read)

      if parsed != nil
        parsed['applist']['apps'].each do |app|
          if name.downcase == app['name'].downcase
            appid = app['appid']
          end
        end       
      end
    rescue => e
      puts "JSON failed to parse #{url}"
    end

    return appid
  end

  def Game.name_from_profile(player)
    name = nil
    page = lookup(player["profileurl"])

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
end
