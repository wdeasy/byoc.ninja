class Game < ActiveRecord::Base
  require 'open-uri'

  self.primary_key = :gameid
  has_many :servers, :foreign_key => :gameid
  belongs_to :protocols, :foreign_key => :protocol  

  def Game.update(player)
  	Game.where(gameid: player["gameid"]).first_or_create do |game|
      name = name_from_gameid(player)

      game.gameextrainfo = name
      game.protocol = Protocol.lookup(name)
      game.gameid = player["gameid"]
  	end
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

    if name.blank? || name == "Welcome to Steam" || (name[0,5] == "Save " && name[-9,9] == " on Steam")
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