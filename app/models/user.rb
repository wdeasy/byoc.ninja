class User < ActiveRecord::Base
  require 'open-uri'

  self.primary_key = :steamid
  belongs_to :server, :foreign_key => :gameserverip, counter_cache: true
  belongs_to :seats, :foreign_key => :seat

  def User.update(player)
    user = User.find_by_steamid(player["steamid"])
    if player["gameserverip"].present?
      gameserverip = player["gameserverip"]
    elsif player["lobbysteamid"].present?
      gameserverip = player["lobbysteamid"]
    end

    if (player["gameserverip"].present? && player["gameserverip"] == user["gameserverip"]) || (player["lobbysteamid"].present? && player["lobbysteamid"] == user["lobbysteamid"])
      user.update_attributes(
        :updated => true
      )  
    else
      user.update_attributes(
        :gameserverip => gameserverip,
        :updated => true
      )  
    end

    if (player["personaname"] != user["personaname"] || player["profileurl"] != user["profileurl"]) && user.auto_update == true
      user.update_attributes(
        :personaname => player["personaname"],
        :profileurl => player["profileurl"],
        :avatar => player["avatar"]
      )
    end  

    Server.reset_counters(gameserverip, :users)     
  end

  def User.lookup(steamid)
    user = User.where(steamid: steamid).first_or_create
  end

  def User.is_member(player)
    if player.display == true
      url = player.profileurl + "?xml=1"
      begin
        doc = Nokogiri::XML(open(url))
      rescue => e
        return true
      end
      if doc != nil
        if doc.at_css("privacyState").text == "public"

          groups = Group.where(:enabled => true)

          doc.xpath('//groupID64').each do |gid|
            groups.each do |g|
              if gid.text == g.groupid64.to_s
                return true
              end
            end
          end
          return false 
        end
      end
    end
    return true
  end
end