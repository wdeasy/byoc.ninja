class Host < ApplicationRecord
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
            host.game_id != nil && host.game_id != host.game.id,
            host.last_successful_query < 1.hour.ago
          info        = Host.get_server_info(player["gameserverip"])
          query_port  = info["query_port"]
          lan         = info["lan"]
        else
          query_port  = host.query_port
          lan         = nil
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
    lan         = (host.lan != nil && lan == nil) ? host.lan : lan

    host.update_attributes(
      :game_id    => game_id,
      :query_port => query_port,
      :ip         => i,
      :port       => port,
      :network_id => network.id,
      :address    => address,
      :lobby      => lobby,
      :link       => link,
      :steamid    => steamid,
      :lan        => lan
    )

    visible = false

    if host.source == 'manual'
      visible = true
    else
      case
      when host.banned == true
        puts "Host is banned"
      when ['banned','private'].include?(host.network.name)
        puts "Network is #{host.network.name}"
      when host.port == 0
        puts "Host port is 0"
      when host.lobby == nil && valid_ip == false
        puts "Host address is invalid"
      when host.respond == false && host.last_successful_query < 1.hour.ago && host.users_count < 2
        puts "Host is not responding"
      when host.lan == true && host.network.name != "byoc"
        puts "Host is a lan game outside of quakecon"
      else
        visible = true
      end
    end

    if visible == true
      if host.ip != nil && host.query_port != nil && valid_ip == true
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
          flags['BYOC Player in Game'] = true
        end
      end

      if ["quakecon", "qcon"].any? { |q| user.name.downcase.include? q }
        flags['BYOC Player in Game'] = true
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
    if host.respond == false
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
      puts "Unable to query #{ip}:#{query_port}"
      return nil
    end
  end

  def Host.update_server_info(host)
    if host.last_successful_query < 1.minute.ago
      server = Host.query_host(host.ip, host.query_port)

      if server != nil
        name = (server.server_info[:server_name] && host.auto_update == true) ? server.server_info[:server_name] :  host.name
        map = (server.server_info[:map_name] && host.auto_update == true) ? server.server_info[:map_name] : host.name
        current = server.server_info[:number_of_players] ? server.server_info[:number_of_players] : host.current
        max = server.server_info[:max_players] ? server.server_info[:max_players] : host.max
        password = server.server_info[:password_needed] ? server.server_info[:password_needed] : host.password

          host.update_attributes(
            :name => valid_name(name),
            :map => valid_name(map),
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
      elsif host.last_successful_query != Time.at(0)
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
        doc = Nokogiri::XML(open("https://steamcommunity.com/gid/#{group.steamid.to_s}/memberslistxml/?xml=1"))
      rescue => e
        puts "Nokogiri failed to open XML https://steamcommunity.com/gid/#{group.steamid.to_s}/memberslistxml/?xml=1"
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

    puts "#{l} steamids from linked seats not in groups, #{linked_users.count} total"

    return steamids
  end

  def Host.update_hosts
    steamids = gather_steamids

    return "No steam ids to process" if steamids.empty?

    Host.update_all(:updated => false)
    User.update_all(:updated => false)

    i = 1
    j = 0
    u = 0
    x = 0
    n = 0

    servers = []
    lobbies = []

    combined = ''
    string = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{ENV['STEAM_WEB_API_KEY']}&steamids="

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
            if player["gameid"] != nil
              user = User.lookup(player["steamid"])
              if user.banned == false && user.display == true

                if player["gameserverip"] != nil || player["lobbysteamid"] != nil
                  if player["gameid"].length > 7
                    #gameids over length 7 are mods
                    game_id = Mod.update(player, true)
                  else
                    game_id = Game.update(player["gameid"],player["gameextrainfo"], true)
                  end
                else
                  if player["gameid"].length > 7
                    #gameids over length 7 are mods
                    game_id = Mod.update(player, false)
                  else
                    game_id = Game.update(player["gameid"],player["gameextrainfo"], false)
                  end
                end

                puts "User: #{player["personaname"]}, #{player["gameextrainfo"]}"
                if player["gameserverip"] != nil && player["lobbysteamid"] != nil
                  puts "-> Server: #{player["gameserverip"]}"
                  puts "-> Lobby: #{player["lobbysteamid"]}"
                elsif player["gameserverip"] != nil
                  puts "-> Server: #{player["gameserverip"]}"
                elsif player["lobbysteamid"] != nil
                  puts "-> Lobby: #{player["lobbysteamid"]}"
                end

                if player["gameserverip"] != nil || player["lobbysteamid"] != nil
                  host_id = Host.update(player, game_id)
                  User.update(player, host_id, game_id)
                  u += 1
                else
                  User.update(player, nil, game_id)
                  n += 1
                end

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
      User.where(:updated => false).update_all(:game_id => nil)
    end

    puts "Processed #{j} steam ids"
    puts "Found #{u+n} users in games"
    puts "Found #{u} users in #{servers.count} servers and #{lobbies.count} lobbies"
    puts "Found #{n} users in non-joinable games"
  end

  def self.get_server_info(address)
    info = {}

    if address != nil
      i, p = address.split(':')
      string = "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{i}&format=json"

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
              info["lan"] = server["lan"]
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
        puts "Searching range #{range.cidr}"
        cidr = NetAddr::CIDR.create(range.cidr)
        i = 0

        until i == cidr.size do
          ip = cidr[i].ip
          api = "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{ip}&format=json"

          begin
            parsed = JSON.parse(open(api).read)

            if parsed != nil && parsed["response"]["success"] == true
              parsed["response"]["servers"].each do |server|
                if server["addr"] && server["appid"] && server["gameport"]
                  x, p = server["addr"].split(':')
                  port = server["gameport"].to_i
                  query_port = p.to_i
                  address = "#{ip}:#{port}"

                  game_id = Game.update(server["appid"],server["gamedir"], true)
                  host = Host.where(address: address).first_or_create

                  host.update_attributes(
                    :game_id    => game_id,
                    :query_port => query_port.to_i,
                    :ip         => ip,
                    :port       => port,
                    :address    => address,
                    :pin        => true,
                    :source     => "byoc"
                  )
                  puts "Found a #{host.game.name} host at #{address}"
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
    puts "Checking #{hosts.count} pins"

    hosts.each do |host|
      puts "#{host.address}"
      visible = false

      if host.source == 'manual'
        visible = true
      else
        case
        when host.address == nil
          puts "Host address is nil"
        when host.last_successful_query < 1.hour.ago
          puts "Host hasn't responded in an hour"
        when host.flags == nil || (host.flags['Hosted in BYOC'] == nil && host.flags['Quakecon in Host Name'] == nil)
          puts "Host is no longer flagged"
        else
          visible = true
        end
      end

      if visible == true
        player = {}
        player["gameserverip"] = host.address

        Host.update(player, host.game_id)
      else
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
    puts "Cleaning up #{hosts.count} pins"

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

    puts "Removed #{i} pins"
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

  def Host.valid_name(name)
    if !name.valid_encoding?
      name = name.encode("UTF-16be", :invalid=>:replace, :replace=>"").encode('UTF-8')
    end
    return name
  end

  def Host.update_hosts_by_name(name)
    if name == nil
      name = "quakecon"
    end

    api = "https://api.steampowered.com/IGameServersService/GetServerList/v1/?filter=\\name_match\\*#{name}*&key=#{ENV['STEAM_WEB_API_KEY']}"

    begin
      parsed = JSON.parse(open(api).read)

      if parsed != nil && parsed["response"]["servers"] != []
        parsed["response"]["servers"].each do |server|
          if server["addr"] && server["appid"] && server["gameport"]
            ip, p = server["addr"].split(':')
            port = server["gameport"].to_i
            query_port = p.to_i
            address = server["addr"]
            flags = {}
            flags['Quakecon in Host Name'] = true
            name = server["name"]
            players = players(server["players"], server["max_players"])
            map = server["map"]

            game_id = Game.update(server["appid"],server["gamedir"], true)
            host = Host.where(address: address).first_or_create

            host.update_attributes(
              :game_id    => game_id,
              :query_port => query_port,
              :ip         => ip,
              :port       => port,
              :address    => address,
              :pin        => true,
              :source     => "host_by_name",
              :flags      => flags,
              :name       => name,
              :players    => players,
              :map        => map
            )

            update_server_info(host)
            puts "Found a #{host.game.name} host at #{address}"
          end
        end
      end
    rescue => e
      puts "JSON failed to parse #{api}"
    end

  end
end
