class Mod < ApplicationRecord
  require 'open-uri'

  belongs_to :game, optional: true
  has_many :users
  has_many :hosts

  def Mod.update(player, supported)
    mod = Mod.where(:steamid => player["gameid"]).first_or_create do |mod|
      info = Host.get_server_info(player["gameserverip"])
      name = Game.name_from_profile(player)

      mod.name = player["gameextrainfo"].blank? ? name : player["gameextrainfo"]
      mod.info = player["gameextrainfo"]
      if info["appid"]
        appid = info["appid"]
        game_id = Game.update(appid, player["gameextrainfo"], supported)

        mod.dir = info["gamedir"]
        mod.game_id = game_id
      else
        appid = Game.appid_from_name(name)
        if appid != nil
          game_id = Game.update(appid, player["gameextrainfo"], supported)

          mod.game_id = game_id
        end
      end
    end

    return mod.id
  end
end
