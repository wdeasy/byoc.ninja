class Host < ActiveRecord::Base
  require 'open-uri'

  self.primary_key = :gameserverip
  belongs_to :game, :foreign_key => :gameid
  has_many :users, :foreign_key => :gameserverip

  def to_param
    gameserverip.parameterize
  end


  def as_json(options={})
    super(:only => [:gameserverip,:name,:map,:users_count,:flags],
          :methods => [:player_count],
          :include => {
            :users => {:only => [:personaname, :profileurl]},
            :game => {:only => [:gameextrainfo, :store_link]}
          }
    )
  end

  def player_count
    if current != nil && max != nil
      "#{current}/#{max}"
    end
  end

  def self.slug(gameserverip)
    return gameserverip.parameterize
  end

  def Host.update(player)
    if player["gameserverip"].present?
      host = Host.where(gameserverip: player["gameserverip"]).first_or_create do |h|
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

      host = Host.where(gameserverip: player["lobbysteamid"]).first_or_create do |h|
          h.gameid            = player["gameid"]
          h.name              = "#{personaname}'s Lobby"
          h.slug              = slug(player["lobbysteamid"])
          h.lobbysteamid      = player["lobbysteamid"].present? ? player["lobbysteamid"] : nil
      end
    end

    if host.network == 'banned' && host.banned == false
      host.update_attributes(
        :banned            => true,
        :visible           => false
      )
    end

    if host.banned == false && host.network != 'private'
      if host["gameid"] == player["gameid"] && host.refresh == false
        host.update_attributes(
          :updated => true,
          :visible => true
        )
      else
        host.update_attributes(
          :gameid                 => player["gameid"],
          :query_port             => find_query_port(player),
          :refresh                => false,
          :updated                => true,
          :visible                => true
        )
      end

      if host.query_port != nil
        query_host(host)
      end

      flags(player,host)
    end
  end

  def Host.flags(player,host)
    flags = ''

    #check for quakecon in hostname
    if host.name != nil
      if host.name.downcase.include? "quakecon"
        if host.name.ends_with? "'s Lobby"
        else
          flags << 'Quakecon in Host Name,'
        end       
      end 
    end

    #byoc player in game
    host.users.each do |user|
      i = 0
      if user.seat.blank?
      else
        i = 1
      end

      if i == 1 or ["quakecon", "qcon"].any? { |q| user.personaname.downcase.include? q }       
        if flags.include? "BYOC Player in Game"
        else
          flags << 'BYOC Player in Game,'
        end       
      end
    end

    #hosted in byoc
    if host.network == "byoc"
      flags << 'Hosted in BYOC,'
    end

    #password protected
    if host.password == true
      flags << 'Password Protected,'
    end

    #is the server responding to queries?
    if host.respond == false && host.last_successful_query != Time.at(0)
      flags << 'Last Query Attempt Failed,'
    end 

    unless flags == ''
      host.update_attributes(
        :flags                 => flags
      )
    end
  end

  def Host.query_host(host)
    server = nil
    server_name = nil
    map_name = nil
    number_of_players = nil
    max_players = nil
    password_needed = nil

    begin
      server = SourceServer.new(host.ip, host.query_port)
      server.init
    rescue => e
      puts "unable to query #{host.ip}:#{host.query_port.to_s}"
    end

    if server != nil
      server_name = server.server_info[:server_name]
      map_name = server.server_info[:map_name]
      number_of_players = server.server_info[:number_of_players]
      max_players = server.server_info[:max_players]
      password_needed = server.server_info[:password_needed]

      host.update_attributes(
        :name => server_name,
        :map => map_name,
        :current => number_of_players,
        :max => max_players,
        :password => password_needed
      )
    end
    
  end

  def Host.update_network(gameserverip, network)
    host = Host.where(gameserverip: gameserverip).first
    host.update_attributes(
      :network           => network
    )
  end

  def Host.update_hosts
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

        Host.update_all(:updated => false)
        User.update_all(:updated => false)

      i = 1
      j = 0
      s = 0
      u = 0
      x = 0

      combined = ''
      string = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_WEB_API_KEY']}&steamids="

      #iterate through steam ids to find hosts
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
                  Host.update(player)
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
        Host.where(:updated => false).update_all(:visible => false)
        User.where(:updated => false).update_all(:gameserverip => nil)
      end

      return "Processed #{j} steam ids. Found #{u} users in #{s} hosts."    
  end

  def Host.find_query_port(player)
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
    end

    return query_port    
  end
end