class Game < ActiveRecord::Base
  require 'open-uri'

  has_many :hosts
  has_many :mods  

  def Game.update(appid, info)
    game = Game.where(appid: appid).first_or_create do |game|
      name = name_from_appid(appid)

      game.name = name
      game.info = info

      if name.exclude? "Source SDK"
         game.link = "http://store.steampowered.com/app/#{appid}"
         game.image = "http://cdn.akamai.steamstatic.com/steam/apps/#{appid}/header.jpg"
      end
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
end