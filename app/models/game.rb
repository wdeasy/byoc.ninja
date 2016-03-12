class Game < ActiveRecord::Base
  require 'open-uri'

  has_many :hosts  

  def Game.update(player)
  	game = Game.where(steamid: player["gameid"]).first_or_create do |game|
      name = name_from_gameid(player)

      game.name = name
      game.steamid = player["gameid"]
      game.info = player["gameextrainfo"]

      if player["gameid"].length < 7
         game.link = "http://store.steampowered.com/app/#{player['gameid']}"
         game.image = "http://cdn.akamai.steamstatic.com/steam/apps/#{player['gameid']}/header.jpg"
      end
    end

    return game.id
  end

  def self.name_from_gameid(player)
    name = ''

    if player["gameid"].length < 7
      url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0002/'

      begin
        parsed = JSON.parse(open(url).read)
      rescue => e
        puts "JSON failed to parse #{url}"
      end

      if parsed != nil
        parsed['applist']['apps'].each do |app|
          if player["gameid"] == app['appid'].to_s
            name = app['name']
          end
        end       
      end
    else
      url = player["profileurl"]

      begin
        html = open(url) 
        page = Nokogiri::HTML(html.read)
      rescue => e
        puts "Nokogiri failed to open HTML #{url}"
      end

      if !page.blank?
        name = page.css('div.profile_in_game_name').text
      end
    end
   
    return name
  end
end