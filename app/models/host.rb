class Host < ActiveRecord::Base
  require 'open-uri'
  require 'socket'
  require 'timeout'
  require 'json'

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
      i, p        = player["gameserverip"].split(':')
      valid_ip    = Network.valid_ip(i)
      port        = p.to_i
      if valid_ip == true
        case
        when host.query_port == nil,       
            host.game_id != nil && (host.game_id != host.game.id),
            host.last_successful_query != Time.at(0) && host.last_successful_query < (Time.now - 1.hour)
          info        = Host.get_server_info(player["gameserverip"])
          query_port  = info["query_port"]
        else
          query_port  = host.query_port
        end
        network     = Network.location(i)        
      else
        query_port  = nil
        network     = Network.location(nil)
      end
    else
      i           = nil
      port        = nil
      query_port  = nil
      network     = Network.location(nil)
      valid_ip    = true      
    end

    link        = link(player)    
    lobby       = player["lobbysteamid"] ? player["lobbysteamid"] : nil
    address     = player["gameserverip"] ? player["gameserverip"] : nil
    steamid     = player["gameserversteamid"] ? player["gameserversteamid"] : nil
    query_port  = (host.query_port != nil && query_port == nil) ? host.query_port : query_port

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

    case
    when host.banned == true,
        ['banned','private'].include?(host.network.name),
        host.port == 0,
        host.last_successful_query != Time.at(0) && host.last_successful_query < (Time.now - 1.hour) && host.source != 'manual',
        host.lobby == nil && valid_ip == false
      puts "This host does not qualify to be visible."
    else
      if host.query_port != nil && valid_ip == true
        update_server_info(host)
      end

      host.update_attributes(
        :flags => flags(host),
        :updated => true,
        :visible => true
      )      
    end
    
    return host.id  
  end

  def Host.flags(host)
    flags = {}

    #check for quakecon in hostname
    if host.name != nil
      #if host.name.downcase.include? "quakecon"
      if ["quakecon", "qcon"].any? { |q| host.name.downcase.include? q }   
        flags['Quakecon in Host Name'] = true
        Host.pin(host)       
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
      Host.pin(host)  
    end

    #password protected
    if host.password == true
      flags['Password Protected'] = true  
    end

    #is the server responding to queries?
    if host.respond == false && host.last_successful_query != Time.at(0)
      flags['Last Query Attempt Failed'] = true
    end 

    #server was manually added
    if host.source == "manual"
      flags['Manually Added'] = true
    end

    unless flags.empty? && host.flags.blank?
      return flags
    else
      return nil
    end
  end

  def Host.query_host(ip, query_port)
    begin
      server = SourceServer.new(ip, query_port)
      server.init

      if server != nil
        return server
      else
        return nil
      end

    rescue SteamCondenser::TimeoutError, Errno::ECONNREFUSED
      puts "unable to query #{ip}:#{query_port}"      
      return nil
    end     
  end

  def Host.update_server_info(host)
    if host.last_successful_query == Time.at(0) || host.last_successful_query < (Time.now - 1.minute)
      server = Host.query_host(host.ip, host.query_port)

      if server != nil
        name = (server.server_info[:server_name] && host.auto_update == true) ? server.server_info[:server_name] :  host.name
        map = (server.server_info[:map_name] && host.auto_update == true) ? server.server_info[:map_name] : host.name
        current = server.server_info[:number_of_players] ? server.server_info[:number_of_players] : host.current
        max = server.server_info[:max_players] ? server.server_info[:max_players] : host.max
        password = server.server_info[:password_needed] ? server.server_info[:password_needed] : host.password

        host.update_attributes(
          :name => User.decolor_name(name),
          :map => map,
          :current => current,
          :max => max,
          :players => players(current, max),
          :password => password,
          :respond => true,
          :last_successful_query => Time.now
        )

        if host.game.queryable == false
          host.game.update_attributes(
            :queryable => true
          )      
        end
      else
        host.update_attributes(
          :respond => false
        )
      end      
    end
  end

  def Host.players(current, max)
    players = ''

    if !current.blank? && !max.blank?
      players << "#{current.to_s}/#{max}"
    end

    return players
  end

  def self.gather_steamids
    steamids = []

    puts "Gathering steamids"

    #iterate through groups to gather steam ids
    groups = Group.where(:enabled => true)
    g = 0
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
            g += 1
          end 
        end     
      end
    end

    puts "#{g} steamids from groups"

    l = 0
    linked_users = User.where('id IN (SELECT user_id from seats_users)')

    linked_users.each do |linked_user|
      if !steamids.include? linked_user.steamid.to_s
        steamids << linked_user.steamid.to_s
        l += 1
      end 
    end

    puts "#{l} steamids from linked seats"

    return steamids
  end

  def Host.update_hosts
    steamids = gather_steamids

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

                if player["gameid"].length > 7
                  #gameids over length 7 are mods
                  game_id = Mod.update(player)
                else
                  game_id = Game.update(player["gameid"],player["gameextrainfo"])                  
                end
                
                if game_id != nil
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
        end
        i = 0
        combined = ''
      end
      i += 1
      j += 1    
    end

    Host.update_pins
    
    if x == 0
      Host.where(:updated => false).update_all(:visible => false)
      User.where(:updated => false).update_all(:host_id => nil)
    end

    return "Processed #{j} steam ids. Found #{u} users in #{servers.count} servers and #{lobbies.count} lobbies."    
  end

  def self.get_server_info(address)
    info = {}

    if address != nil
      i, p = address.split(':')
      string = "http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{i}&format=json"

      begin
        parsed = JSON.parse(open(string).read)

        if parsed != nil && parsed["response"]["success"] == true
          info["respond"] = false
          parsed["response"]["servers"].each do |server|
            gameport = server["gameport"]
            if gameport.to_i == p.to_i
              ip, po = server["addr"].split(':')
              info["query_port"] = po.to_i
              info["gamedir"] = server["gamedir"]
              info["appid"] = server["appid"]
              info["respond"] = true
            end 
          end
        else
          puts parsed["response"]["message"]
        end
      rescue => e
        puts "JSON failed to parse #{string}"
      end
    end

    return info  
  end

  def Host.update_byoc
    Network.where(:name => 'byoc').each do |range|
      if !range.cidr.blank?
        puts "searching range #{range.cidr}"
        cidr = NetAddr::CIDR.create(range.cidr)
        i = 0  

        until i == cidr.size do
          ip = cidr[i].ip
          api = "http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{ip}&format=json"

          begin
            parsed = JSON.parse(open(api).read)

            if parsed != nil && parsed["response"]["success"] == true              
              parsed["response"]["servers"].each do |server|
                if server["addr"] && server["appid"] && server["gameport"]                  
                  x, p = server["addr"].split(':')
                  port = server["gameport"].to_i
                  query_port = p.to_i
                  address = "#{ip}:#{port}"
                  
                  game_id = Game.update(server["appid"],server["gamedir"])
                  host = Host.where(address: address).first_or_create

                  host.update_attributes(
                    :game_id    => game_id,
                    :query_port => query_port.to_i,
                    :ip         => ip,
                    :port       => port,
                    :address    => address,
                    :pin        => true,
                    :source     => "scan"
                  )
                  puts "Found a #{host.game.name} host at #{address}."                
                end
              end
            end
          rescue => e
            puts "JSON failed to parse #{api}"
          end

          i += 1
          sleep(1.second)
        end
      end
    end
  end

  def Host.update_pins
    #pins are hosts that are allowed to stay up even when member count is zero.
    hosts = Host.where(:pin => true, :updated => false)
    puts "Checking #{hosts.count} pins."

    hosts.each do |host|
      puts "#{host.address}"
      if host.address != nil || host.source = 'manual'
        player = {}
        player["gameserverip"] = host.address

        Host.update(player, host.game_id)
      end

      if (host.address == nil || (host.respond == false && host.last_successful_query < (Time.now - 1.hour) && host.last_successful_query != Time.at(0))) && host.source != 'manual'
        Host.unpin(host)
      end
    end
  end

  def Host.pin(host)
    if host.pin == false
      puts "Pinning #{host.ip}:#{host.query_port}" 
      host.update_attributes(
        :pin => true
      )
    end
  end

  def Host.unpin(host)
    if host.pin == true
      puts "Unpinning #{host.ip}:#{host.query_port}"
      host.update_attributes(
        :pin => false
      )
    end
  end

  def Host.cleanup_pins
    hosts = Host.where(:pin => true)
    puts "Cleaning up #{hosts.count} pins."

    i = 0
    hosts.each do |host|
      if host.source != "manual"
        if host.address == nil
          Host.unpin(host)
          i += 1
        else
          info = Host.get_server_info(host.address)

          if host.port == nil || info["query_port"] == nil
            Host.unpin(host)
            i += 1
          end
        end
      end
    end

    puts "Removed #{i} pins."
  end

  def self.port_open(ip, port, seconds=1)
    Timeout::timeout(seconds) do
      begin
        TCPSocket.new(ip, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
        false
      end
    end
  rescue Timeout::Error
    false
  end
end
