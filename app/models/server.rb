class Server < ActiveRecord::Base
  require 'open-uri'

  self.primary_key = :gameserverip
  belongs_to :game, :foreign_key => :gameid
  has_many :users, :foreign_key => :gameserverip

  def to_param
    gameserverip.parameterize
  end

  def self.slug(gameserverip)
    return gameserverip.parameterize
  end

  def Server.update(player)
    if player["gameserverip"].present?
      server = Server.where(gameserverip: player["gameserverip"]).first_or_create do |h|
          i, p = player["gameserverip"].split(':')
          port = p.to_i

          h.gameid            = player["gameid"]
          h.query_port        = find_query_port(player)
          h.ip                = i
          h.port              = port
          h.network           = Network.location(i)
          h.slug              = slug(player["gameserverip"])
          h.lobbysteamid      = player["lobbysteamid"].present? ? player["lobbysteamid"] : nil
      end
    elsif player["lobbysteamid"].present? && !player["gameserverip"].present?
      user = User.find_by_steamid(player["steamid"])
      if user.seat.blank?
        personaname = player["personaname"]
      else
        seat = Seat.find_by_seat(user.seat)
        personaname = "[#{seat.seat}] #{seat.handle}"
      end      

      server = Server.where(gameserverip: player["lobbysteamid"]).first_or_create do |h|
          h.gameid            = player["gameid"]
          h.name              = "#{personaname}'s Lobby"
          h.slug              = slug(player["lobbysteamid"])
          h.lobbysteamid      = player["lobbysteamid"].present? ? player["lobbysteamid"] : nil
      end
    end

    if server.network == 'banned' && server.banned == false
      server.update_attributes(
        :banned            => true,
        :visible           => false
      )
    end

    if server.banned == false && server.network != 'private'
      if server["gameid"] == player["gameid"] && server.refresh == false
        server.update_attributes(
          :updated => true,
          :visible => true
        )
      else
        server.update_attributes(
          :gameid                 => player["gameid"],
          :query_port             => find_query_port(player),
          :refresh                => false,
          :updated                => true,
          :visible                => true
        )
      end
    end
  end

  def Server.update_network(gameserverip, network)
    server = Server.where(gameserverip: gameserverip).first
    server.update_attributes(
      :network           => network
    )
  end

  def Server.update_servers
    steamids = []

    #iterate through groups to gather steam ids
    groups = Group.where(:enabled => true)
      groups.each do |group|
        begin
          doc = Nokogiri::XML(open("http://steamcommunity.com/gid/#{group.groupid64.to_s}/memberslistxml/?xml=1"))
        rescue => e
          puts "Nokogiri failed to open XML http://steamcommunity.com/gid/#{group.groupid64.to_s}/memberslistxml/?xml=1"
        end

        if doc != nil
          doc.xpath('//steamID64').each do |steamid|
            if !steamids.include? steamid.text
              steamids << steamid.text
            end 
          end     
        end
      end

      return "no steam ids to process." if steamids.empty?

        Server.update_all(:updated => false)
        User.update_all(:updated => false)

      i = 1
      j = 0
      s = 0
      u = 0
      x = 0

      combined = ''
      string = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_WEB_API_KEY']}&steamids="

      #iterate through steam ids to find servers
      steamids.each do |steamid|
        combined << steamid.to_s + ','
        
        #GetPlayerSummaries has a max of 100 steam ids
        if i == 100 || steamid == steamids.last
          begin
            parsed = JSON.parse(open(string + combined).read)
          rescue => e
            puts "JSON failed to parse #{string + combined}"
            x = 1
          end

          if parsed != nil
            parsed["response"]["players"].each do |player|
              if player["gameserverip"] != nil || player["lobbysteamid"] != nil
                user = User.lookup(player["steamid"])
                if user.banned == false && user.display == true
                  Game.update(player)
                  Server.update(player)
                  s += 1
                  User.update(player)
                  u += 1
                end
              end 
            end
          end
          i = 0
          combined = ''
        end
        i += 1
        j += 1    
      end

      if x == 0
        Server.where(:updated => false).update_all(:visible => false)
        User.where(:updated => false).update_all(:gameserverip => nil)
      end

      system("php lib/tasks/servers.php #{ENV["GAMEQ_PATH"]} #{ENV["HOSTNAME"]} #{ENV["DATABASE"]} #{ENV["USERNAME"]} #{ENV["PASSWORD"]}")

      return "Processed #{j} steam ids. Found #{u} users in #{s} servers."    
  end

  def Server.find_query_port(player)
    query_port = nil

    if player["gameserverip"] != nil
      i, p = player["gameserverip"].split(':')
      string = "http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{i}&format=json"

      begin
        parsed = JSON.parse(open(string).read)
      rescue => e
        puts "JSON failed to parse #{string}"
      end

      if parsed != nil && parsed["response"]["success"] == true
        parsed["response"]["servers"].each do |server|
          gameport = server["gameport"]
          if gameport.to_i == p.to_i
            ip, po = server["addr"].split(':')
            query_port = po.to_i
          end 
        end
      else
        puts parsed["response"]["message"]
      end

      if query_port != nil
        game = Game.where(gameid: player["gameid"]).first

        if game["protocol"] == nil
          game.update_attributes(
            :protocol   => "source"
          )
        end        
      end
    end

    return query_port    
  end
end