class Mod < ActiveRecord::Base
  require 'open-uri'

  belongs_to :game

  def Mod.update(player, supported)
    mod = Mod.where(:steamid => player["gameid"]).first_or_create do |mod|
      info = Host.get_server_info(player["gameserverip"])
      if info["appid"]
        appid = info["appid"]
        mod.dir = info["gamedir"]
        mod.info = player["gameextrainfo"]
        game_id = Game.update(appid, player["gameextrainfo"], supported)
        mod.game_id = game_id
      else
        name = Game.name_from_profile(player)
        appid = Game.appid_from_name(name)
        mod.info = player["gameextrainfo"]
        if appid != nil
          game_id = Game.update(appid, player["gameextrainfo"], supported)
          mod.game_id = game_id           
        end
      end
    end

    return mod.game_id  
  end
end


