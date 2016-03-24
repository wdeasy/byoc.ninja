class Host < ActiveRecord::Base
  require 'open-uri'

  belongs_to :game
  belongs_to :network
  has_many :users
  has_many :seats, :through => :users

  serialize :flags

  def as_json(options={})
   super(:only => [:name,:map,:users_count,:address,:lobby,:players,:flags,:link],
          :include => {
            :users => {:only => [:name, :url],
              :include => { 
                :seats => {:only => [:seat, :clan, :handle]}
              }
            },
            :game => {:only => [:name, :link]}            
          }
    )
  end

  def Host.link(player)
    if player["lobbysteamid"].present?
      "steam://joinlobby/#{player["gameid"]}/#{player["lobbysteamid"]}/#{player["steamid"]}"
    else
      "steam://connect/#{player["gameserverip"]}"
    end
  end

  def Host.update(player, game_id)
    if player["lobbysteamid"].present? && player["gameserverip"].present?
      host = Host.where('lobby = ? OR address = ?', player["lobbysteamid"], player["gameserverip"]).first_or_create
    elsif player["lobbysteamid"].present?
      host = Host.where(lobby: player["lobbysteamid"]).first_or_create
    elsif player["gameserverip"].present?
      host = Host.where(address: player["gameserverip"]).first_or_create
    end

    if player["gameserverip"]
      i, p = player["gameserverip"].split(':')
      port = p.to_i
      query_port        = find_query_port(player)
      network        = Network.location(i)
    else
      i = nil
      port = nil
      query_port = nil
      network = Network.location(nil)
    end

    link        = link(player)
    lobby       = player["lobbysteamid"] ? player["lobbysteamid"] : nil
    address     = player["gameserverip"] ? player["gameserverip"] : nil
    steamid     = player["gameserversteamid"] ? player["gameserversteamid"] : nil
  
    host.update_attributes(
      :game_id    => game_id,
      :query_port => query_port,
      :ip         => i,
      :port       => port,
      :network_id => network.id,
      :address    => address,
      :lobby      => lobby,
      :link       => link,
      :steamid    => steamid
    )

    if host.banned == false && ['banned','private'].exclude?(host.network.name) && host.auto_update == true && host.port != 0
      if host.query_port != nil
        query_host(host)
      end

      flags(player,host)

      host.update_attributes(
        :updated => true,
        :visible => true
      )
    end   
    
    return host.id  
  end

  def Host.flags(player,host)
    flags = {}

    #check for quakecon in hostname
    if host.name != nil
      if host.name.downcase.include? "quakecon"
        flags['Quakecon in Host Name'] = true       
      end 
    end

    #byoc player in game
    host.users.each do |user|
      user.seats.each do |seat|
        if seat.year == Date.today.year
          if flags['BYOC Player in Game']
          else
            flags['BYOC Player in Game'] = true  
          end              
        end
      end

      if ["quakecon", "qcon"].any? { |q| user.name.downcase.include? q }       
        if flags['BYOC Player in Game']
        else
          flags['BYOC Player in Game'] = true  
        end       
      end
    end

    #hosted in byoc
    if host.network.name == "byoc"
      flags['Hosted in BYOC'] = true  
    end

    #password protected
    if host.password == true
      flags['Password Protected'] = true  
    end

    #is the server responding to queries?
    if host.respond == false && host.last_successful_query != Time.at(0)
      flags['Last Query Attempt Failed'] = true  
    end 

    unless flags.empty? && host.flags.blank?
      host.update_attributes(
        :flags                 => flags
      )
    end
  end

  def Host.query_host(host)
    server = nil
    name = nil
    map = nil
    current = nil
    max = nil
    password = nil

    begin
      server = SourceServer.new(host.ip, host.query_port)
      server.init

      if server != nil
        name = server.server_info[:server_name]
        map = server.server_info[:map_name]
        current = server.server_info[:number_of_players]
        max = server.server_info[:max_players]
        password = server.server_info[:password_needed]

        host.update_attributes(
          :name => name,
          :map => map,
          :current => current,
          :max => max,
          :players => players(current, max),
          :password => password,
          :respond => true,
          :last_successful_query => Time.now
        )
      else
        host.update_attributes(
          :respond => false
        )
      end

    rescue SteamCondenser::TimeoutError
      puts "unable to query #{host.ip}:#{host.query_port.to_s}"

      host.update_attributes(
        :respond => false
      )
    end  
  end

  def Host.players(current, max)
    players = ''

    if max.blank?
    else
      if !current.blank? && current > 0
        players << "#{current.to_s}/#{max}"
      end
    end

    return players
  end

  def Host.update_hosts
    steamids = []

    #iterate through groups to gather steam ids
    groups = Group.where(:enabled => true)
      groups.each do |group|
        begin
          doc = Nokogiri::XML(open("http://steamcommunity.com/gid/#{group.steamid.to_s}/memberslistxml/?xml=1"))
        rescue => e
          puts "Nokogiri failed to open XML http://steamcommunity.com/gid/#{group.steamid.to_s}/memberslistxml/?xml=1"
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
      u = 0
      x = 0

      servers = []
      lobbies = []

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
                  game_id = Game.update(player)
                  host_id = Host.update(player, game_id)
                  User.update(player, host_id)
                  u += 1

                  if player["gameserverip"] != nil
                    if !servers.include? player["gameserverip"]
                      servers.push(player["gameserverip"])
                    end
                  end

                  if player["lobbysteamid"] != nil
                    if !lobbies.include? player["lobbysteamid"]
                      lobbies.push(player["lobbysteamid"])
                    end
                  end

                  if player["gameserverip"] != nil && player["lobbysteamid"] != nil
                    puts "user: #{player["personaname"]}, server: #{player["gameserverip"]}, lobby: #{player["lobbysteamid"]}"
                  elsif player["gameserverip"] != nil
                    puts "user: #{player["personaname"]}, server: #{player["gameserverip"]}"
                  else
                    puts "user: #{player["personaname"]}, lobby: #{player["lobbysteamid"]}"
                  end
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
        User.where(:updated => false).update_all(:host_id => nil)
      end

      return "Processed #{j} steam ids. Found #{u} users in #{servers.count} servers and #{lobbies.count} lobbies."    
  end

  def Host.find_query_port(player)
    query_port = nil

    if player["gameserverip"] != nil
      i, p = player["gameserverip"].split(':')
      string = "http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{i}&format=json"

      begin
        parsed = JSON.parse(open(string).read)

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
      rescue => e
        puts "JSON failed to parse #{string}"
      end
    end

    return query_port    
  end
end