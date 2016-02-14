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

    page = lookup("http://store.steampowered.com/app/#{player["gameid"]}")
    if !page.blank?
      name = page.css('div.apphub_AppName').text

      if name.blank?
        name = page.css('title').text
        name.slice!(" on Steam")
      end                
    end

    if name.blank? || name == "Welcome to Steam" || name[0,5] == "Save "
      page = lookup(player["profileurl"])
      if !page.blank?
        name = page.css('div.profile_in_game_name').text
      end
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