class Game < ActiveRecord::Base
  require 'open-uri'

  has_many :hosts  

  def Game.update(player)
  	game = Game.where(steamid: player["gameid"]).first_or_create do |game|
      name = name_from_gameid(player)

      game.name = name
      game.steamid = player["gameid"]

      if player["gameid"].length < 7
         game.store_link = "http://store.steampowered.com/app/#{player['gameid']}"
         game.comm_link = "http://steamcommunity.com/app/#{player['gameid']}"
         game.full_img = "http://cdn.akamai.steamstatic.com/steam/apps/#{player['gameid']}/header.jpg"
      end
    end

    return game.id
  end

  def self.name_from_gameid(player)
    name = ''
    url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0001/'

    begin
      parsed = JSON.parse(open(url).read)
    rescue => e
      puts "JSON failed to parse #{url}"
    end

    if parsed != nil
      parsed['applist']['apps']['app'].each do |app|
        if player["gameid"] == app['appid'].to_s
          name = app['name']
        end
      end       
    end
   
    return name
  end
end