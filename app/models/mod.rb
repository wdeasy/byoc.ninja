class Mod < ApplicationRecord
  require 'open-uri'

  belongs_to :game, optional: true
  has_many :users
  has_many :hosts

  def Mod.update(player, supported)
    mod = Mod.where(:steamid => player["gameid"]).first_or_create do |mod|
      info = Host.get_server_info(player["gameserverip"])
      name = Game.name_from_profile(player["profileurl"])
      game_id = nil

      mod.name = player["gameextrainfo"].blank? ? name : player["gameextrainfo"]
      mod.info = player["gameextrainfo"]
      if info["appid"]
        appid = info["appid"]
        game_id = Game.update(appid, player["gameextrainfo"], supported, player["profileurl"])

        mod.dir = info["gamedir"]
      else
        appid = Game.appid_from_name(name)
        game_id = Game.update(appid, player["gameextrainfo"], supported)
      end

      mod.game_id = game_id
    end

    return mod.id
  end
end
