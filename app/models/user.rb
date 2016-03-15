class User < ActiveRecord::Base
  require 'open-uri'

  belongs_to :host, counter_cache: true
  has_and_belongs_to_many :seats 

  def User.update(player, host_id)

    user = User.find_by_steamid(player["steamid"])

    if (player["gameserverip"].present? && player["gameserverip"] == user["address"]) || (player["lobbysteamid"].present? && player["lobbysteamid"] == user["lobby"])
      user.update_attributes(
        :updated => true
      )  
    else
      user.update_attributes(
        :host_id => host_id,
        :updated => true
      )  
    end

    if (player["personaname"] != user["name"] || player["profileurl"] != user["url"]) && user.auto_update == true

      user.update_attributes(
        :name => player["personaname"],
        :url => player["profileurl"],
        :avatar => player["avatar"]
      )
    end  

    Host.reset_counters(host_id, :users)     
  end

  def User.lookup(steamid)
    user = User.where(steamid: steamid).first_or_create
  end

  def User.is_member(player)
    if player.display == true
      url = player.url + "?xml=1"
      begin
        doc = Nokogiri::XML(open(url))
      rescue => e
        return true
      end
      if doc != nil
        if doc.at_css("privacyState")
          if doc.at_css("privacyState").text == "public"
            groups = Group.where(:enabled => true)
            doc.xpath('//groupID64').each do |gid|
              groups.each do |g|
                if gid.text == g.steamid.to_s
                  return true
                end
              end
            end
            return false 
          end
        else
          return true
        end
      end
    end
    return true
  end
end