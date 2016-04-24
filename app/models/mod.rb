class Mod < ActiveRecord::Base
  require 'open-uri'

  belongs_to :game

  def Mod.update(player)
    mod = Mod.where(:steamid => player["gameid"]).first_or_create do |mod|
      info = Host.get_server_info(player["gameserverip"])
      if info["appid"]
        appid = info["appid"]
        mod.dir = info["gamedir"]
        mod.info = player["gameextrainfo"]
        game_id = Game.update(appid, player["gameextrainfo"])
        mod.game_id = game_id                
      end
    end

    return mod.game_id  
  end
end


