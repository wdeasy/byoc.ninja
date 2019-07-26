class Host < ApplicationRecord
  require 'open-uri'
  require 'socket'
  require 'timeout'
  require 'json'
  require 'csv'

  belongs_to :game
  belongs_to :mod, optional: true
  belongs_to :network
  has_many :users
  has_many :seats, :through => :users

  serialize :flags

  def as_json(options={})
   super(:only => [:name,:map,:users_count,:address,:lobby,:players,:flags,:link,:query_port], :methods => [:location],
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

  def Host.update(player, game_id, mod_id=nil)
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
        when host.query_port == nil || (host.game_id != nil && host.game_id != host.game.id) || host.last_successful_query < 1.hour.ago
          info        = Host.get_server_info(player["gameserverip"])
          query_port  = info["query_port"]
          lan         = info["lan"]
        else
          query_port  = host.query_port
          lan         = nil
        end
        network_id     = Network.location(i)
      else
        query_port  = nil
        network_id     = Network.location(nil)
      end
    else
      i           = nil
      port        = nil
      query_port  = nil
      network_id     = Network.location(nil)
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
      :mod_id     => mod_id,
      :query_port => query_port,
      :ip         => i,
      :port       => port,
      :network_id => network_id,
      :address    => address,
      :lobby      => lobby,
      :link       => link,
      :steamid    => steamid,
      :lan        => lan
    )

    visible = is_visible(host, valid_ip)
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

  def Host.update_host_from_master(server)
    ip, query_port = server[:address].split(':')
    address = "#{ip}:#{server[:port]}"

    host = Host.where(address: address).first_or_create

    if host.updated == false

      if server[:appid].nil?
        server[:appid] = Game.appid_from_name(server[:product])
      end

      game_id  = Game.update(server[:appid],server[:product], true)
      network_id  = Network.location(ip)
      valid_ip = Network.valid_ip(ip)

      host.update_attributes(
        :game_id    => game_id,
        :query_port => query_port,
        :ip         => ip,
        :port       => server[:port],
        :network_id => network_id,
        :address    => address,
        :link       => "steam://connect/#{address}",
        :steamid    => server[:steamid],
        :name       => valid_name(server[:name]),
        :current    => server[:current],
        :max        => server[:max],
        :players    => players(server[:current], server[:max]),
        :map        => valid_name(server[:map]),
        :source     => "name",
        :last_successful_query => Time.now
      )

      visible = is_visible(host, valid_ip)
      if visible == true
        host.update_attributes(
          :flags => flags(host),
          :updated => true,
          :visible => true
        )
      end
    end
  end

  def Host.is_visible(host, valid_ip)
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
      # when host.respond == false && host.last_successful_query < 1.hour.ago && host.users_count < 2 && host.network.name != "byoc"
      #   puts "Host is not responding"
      when host.lan == true && host.network.name != "byoc"
        puts "Host is a lan game outside of quakecon"
      when host.source == "name" && Filter.contains(host.name)
        puts "Host has been filtered out by keyword."
      else
        visible = true
      end
    end

    return visible
  end

  def Host.flags(host)
    flags = {}

    #check for quakecon in hostname
    if host.name != nil
      #if host.name.downcase.include? "quakecon"
      if ["quakecon", "qcon", "byoc"].any? { |q| host.name.downcase.include? q }
        flags['Quakecon in Host Name'] = true
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
      #Host.pin(host)
    end

    #password protected
    if host.password == true
      flags['Password Protected'] = true
    end

    #is the server responding to queries?
    if host.respond == false && host.network.name != "byoc"
      flags['Last Query Attempt Failed'] = true
    end

    #server was manually added
    if host.source == "manual"
      flags['Manually Added'] = true
    end

    #server was added from file
    if host.source == "file"
      flags['Added From File'] = true
    end

    unless flags.empty? && host.flags.blank?
      return flags
    else
      return nil
    end
  end

  def Host.query_host(ip, query_port)
    info = nil

    begin
      server = SourceServer.new(ip, query_port)
      server.init

      if server != nil
        info = {}
        info[:name] = server.server_info[:server_name]
        info[:map] = server.server_info[:map_name]
        info[:current] = server.server_info[:number_of_players]
        info[:max] = server.server_info[:max_players]
        info[:password] = server.server_info[:password_needed]
      end
    rescue SteamCondenser::TimeoutError, Errno::ECONNREFUSED
      puts "Unable to query #{ip}:#{query_port}"
    end

    return info
  end

  def Host.query_master(address)
    api = SteamWebApi.get_server_list_by_address(address)
    parsed = SteamWebApi.get_json(api)
    info = nil

    if parsed != nil && !parsed["response"].empty? && !parsed["response"]["servers"].empty?
      info = {}
      parsed["response"]["servers"].each do |server|
        info[:name] = server["name"]
        info[:map] = server["map"]
        info[:current] = server["players"]
        info[:max] = server["max_players"]
        info[:password] = server["gametype"].nil? ? false : (server["gametype"].include? "pw,")
      end
    else
      puts "No master server info for #{address}"
    end

    return info
  end

  def Host.query_master_by_names
    servers = []
    names = ['quakecon','qcon','byoc']
    names.each do |name|
      puts "Searching for servers that include \"#{name}\"."
      api = SteamWebApi.get_server_list_by_name(name)
      parsed = SteamWebApi.get_json(api)
      info = nil

      if parsed != nil && !parsed["response"].empty? && !parsed["response"]["servers"].empty?
        parsed["response"]["servers"].each do |server|
          puts "-> Server: #{server["addr"]}"

          info = {}
          info[:name]     = server["name"]
          info[:map]      = server["map"]
          info[:current]  = server["players"]
          info[:max]      = server["max_players"]
          info[:password] = server["gametype"].nil? ? false : (server["gametype"].include? "pw,")
          info[:address]  = server["addr"]
          info[:port]     = server["gameport"].to_i
          info[:appid]    = server["appid"]
          info[:product]  = server["product"]
          info[:steamid]  = server["steamid"]
          servers << info
        end
      end
    end

    return servers
  end

  def Host.update_server_info(host)
    if host.last_successful_query < 1.minute.ago
      info = Host.query_host(host.ip, host.query_port)
      if info.nil?
        puts "Unable to query #{host.address} directly. Trying master server."
        info = Host.query_master(host.address)
      end

      if info != nil
        name = (info[:name] && host.auto_update == true) ? info[:name] : host.name
        map = (info[:map] && host.auto_update == true) ? info[:map] : host.name
        current = info[:current] ? info[:current] : host.current
        max = info[:max] ? info[:max] : host.max
        password = info[:password] ? info[:password] : host.password

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
    players = nil

    if !current.blank? && !max.blank?
      current = current.to_i
      max = max.to_i

      if current > max && max > 0
        current = max
      end

      players = "#{current.to_s}/#{max}"
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
      string = SteamWebApi.get_members_list(group.steamid.to_s)
      doc = SteamWebApi.get_xml(string)

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

    #iterate through steam ids to find hosts
    steamids.each do |steamid|
      combined << steamid.to_s + ','

      #GetPlayerSummaries has a max of 100 steam ids
      if i == 100 || steamid == steamids.last
        parsed = SteamWebApi.get_json(SteamWebApi.get_player_summaries + combined)

        if parsed != nil && !parsed["response"].empty? && !parsed["response"]["players"].empty?
          parsed["response"]["players"].each do |player|
            if player["gameid"] != nil
              user = User.lookup(player["steamid"])
              if user.banned == false && user.display == true

                if player["gameserverip"] != nil || player["lobbysteamid"] != nil
                  if player["gameid"].length > 7
                    #gameids over length 7 are mods
                    mod_id = Mod.update(player, true)
                    game_id = Mod.find(mod_id).game_id
                  else
                    game_id = Game.update(player["gameid"],player["gameextrainfo"], true, player["profileurl"])
                  end
                else
                  if player["gameid"].length > 7
                    #gameids over length 7 are mods
                    mod_id = Mod.update(player, false)
                    game_id = Mod.find(mod_id).game_id
                  else
                    game_id = Game.update(player["gameid"],player["gameextrainfo"], false, player["profileurl"])
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
                  host_id = Host.update(player, game_id, mod_id)
                  User.update(player, host_id, game_id, mod_id)
                  u += 1
                else
                  User.update(player, nil, game_id, mod_id)
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
        else
          x = 1
        end
        i = 0
        combined = ''
      end
      i += 1
      j += 1
    end

    #find hosts by name
    name_servers = Host.query_master_by_names
    name_servers.each do |server|
      Host.update_host_from_master(server)
    end
    m = name_servers.count

    #import servers from qclan.info
    file_servers = Host.load_hosts_from_file
    file_servers.each do |server|
      Host.update_host_from_file(server)
    end
    f = file_servers.count

    Host.update_pins

    if x == 0
      Host.where(:updated => false).update_all(:visible => false)
      User.where(:updated => false).update_all(:host_id => nil)
      User.where(:updated => false).update_all(:game_id => nil)
      User.where(:updated => false).update_all(:mod_id => nil)
    end

    puts "Processed #{j} steam ids"
    puts "Found #{u+n} users in games"
    puts "Found #{u} users in #{servers.count} servers and #{lobbies.count} lobbies"
    puts "Found #{n} users in non-joinable games"
    puts "Found #{m} servers by name"
    puts "Found #{f} servers by file"
  end

  def self.get_server_info(address)
    info = {}

    if address != nil
      i, p = address.split(':')
      string = SteamWebApi.get_servers_at_address(i)
      parsed = SteamWebApi.get_json(string)

      if parsed != nil && !parsed["response"].empty? &&  parsed["response"]["success"] == true
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
          api = SteamWebApi.get_servers_at_address(ip)
          parsed = SteamWebApi.get_json(api)

          if parsed != nil && !parsed["response"].empty? &&  parsed["response"]["success"] == true
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
        when host.last_successful_query < 5.minutes.ago
          puts "Host isn't responding"
        when host.flags == nil || (host.flags['Hosted in BYOC'] == nil)
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
    unless name.nil?
      if !name.valid_encoding?
        name = name.encode("UTF-16be", :invalid=>:replace, :replace=>"").encode('UTF-8')
      end

      name.strip!
      name = name.gsub(/[^[:print:]]/i, '')
      name = name.gsub(/(<color[^>]*>)|(<\/color>)/,'')
    end

    return name
  end

  def Host.load_hosts_from_file
    puts "Loading servers by file."
    servers = []

    if ENV["HOSTS_FILE"].nil?
      puts "Host file location is not set."
      return servers
    end

    file = ENV["HOSTS_FILE"]

    if file == nil
      puts "No file specified."
    elsif !File.file?(file)
      puts "File not found."
    elsif File.zero?(file)
      puts "File is empty."
    else
      puts "Reading #{file}..."
      begin
        CSV.new(open(file), liberal_parsing: true).each do |line|
          unless line[0] == nil || (servers.include? line[0])
            puts "-> Server: #{line[0]}"
            info = {}
            info[:address]  = line[0]
            info[:name]     = line[1]
            info[:map]      = line[2]
            info[:product]  = line[3]
            info[:appid]    = line[4]
            info[:current]  = line[5]
            info[:max]      = line[6]
            info[:password] = line[10]
            servers << info
          end
        end
      rescue => e
        puts "Unable to read file #{file}"
        puts e
      end
    end

    return servers
  end

  def Host.update_host_from_file(server)
    host = Host.where(address: server[:address]).first_or_create

    if host.updated == false
      if server[:appid].nil? || server[:appid] == 0
        info = Host.get_server_info(server[:address])
        appid = info["appid"]
        query_port = info["query_port"]
      else
        appid = server[:appid]
        query_port = nil
      end

      if appid.nil?
        appid = Game.appid_from_name(server[:product])
      end

      name = server[:name] == "noname" ? nil : server[:name]

      ip, port = server[:address].split(':')
      game_id = Game.update(appid,server[:product], true)

      network_id = Network.location(ip)
      valid_ip = Network.valid_ip(ip)

      host.update_attributes(
        :game_id    => game_id,
        :query_port => query_port,
        :ip         => ip,
        :port       => port,
        :network_id => network_id,
        :address    => server[:address],
        :link       => "steam://connect/#{server[:address]}",
        :name       => valid_name(name),
        :current    => server[:current],
        :max        => server[:max],
        :players    => players(server[:current], server[:max]),
        :map        => valid_name(server[:map]),
        :source     => "file",
        :last_successful_query => Time.now
      )

      visible = is_visible(host, valid_ip)
      if visible == true
        host.update_attributes(
          :flags => flags(host),
          :updated => true,
          :visible => true
        )
      end
    else
      if host.respond == false && host.source = "file"
        host.update_attributes(
          :name       => valid_name(server[:name]),
          :current    => server[:current],
          :max        => server[:max],
          :players    => players(server[:current], server[:max]),
          :map        => valid_name(server[:map]),
        )
      end
    end

    unless ENV["HOSTS_FILE"].nil?
      File.delete ENV["HOSTS_FILE"] if File.file? ENV["HOSTS_FILE"]
    end
  end

  def Host.deperameterize(address)
    if address.nil?
      return nil
    elsif address !~ /([0-9]{1,3}\-[0-9]{1,3}\-[0-9]{1,3}\-[0-9]{1,3})\-([0-9]{1,5})/
      return nil
    else
      one, two, three, four, five = address.split("-")
      "#{one}.#{two}.#{three}.#{four}:#{five}"
    end
  end

  def location
    network.name
  end
end
