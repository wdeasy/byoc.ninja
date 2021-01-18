class SteamWebApi < ApplicationRecord
  def SteamWebApi.get_key
    steam_key = SteamWebApi.first

    if steam_key.nil? && ENV["STEAM_WEB_API_KEY"].present?
      puts "Adding Steam Web Api Key"
      steam_key = SteamWebApi.create(:key => ENV["STEAM_WEB_API_KEY"].hash)
    elsif steam_key.nil?
      puts "Could not find steam web api key."
      return nil
    end

    if Time.now.day == steam_key.updated_at.day
      steam_key.update(
        :calls  => steam_key.calls+1
      )
    else
      steam_key.update(
        :yesterday => steam_key.calls,
        :calls  => 1
      )
    end

    return ENV["STEAM_WEB_API_KEY"]
  end

  def self.get_json(url)
    parsed = nil

    begin
      parsed = JSON.parse(URI.open(url).read)
    rescue => e
      puts "JSON failed to parse #{url}"
      puts e.message
    end

    return parsed
  end

  def self.get_xml(url)
    parsed = nil

    begin
      parsed = Nokogiri::XML(URI.open(url))
    rescue => e
      puts "Nokogiri failed to open XML #{url}"
      puts e.message
    end

    return parsed
  end

  def self.get_html(url)
    page = nil

    begin
      html = URI.open(url)
      page = Nokogiri::HTML(html.read)
    rescue => e
      puts "Nokogiri failed to open HTML #{url}"
    end

    return page
  end

  def self.get_player_summaries
    "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{get_key}&steamids="
  end

  def self.get_server_list_by_keyword(keyword)
    "https://api.steampowered.com/IGameServersService/GetServerList/v1/?filter=\\name_match\\*#{keyword}*&key=#{get_key}"
  end

  def self.get_server_list_by_address(address)
    "https://api.steampowered.com/IGameServersService/GetServerList/v1/?filter=\\gameaddr\\#{address}&key=#{get_key}"
  end

  def self.get_schema_for_game(appid)
    "https://api.steampowered.com/ISteamUserStats/GetSchemaForGame/v2/?key=#{get_key}&appid=#{appid}"
  end

  def self.get_servers_at_address(address)
    "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=#{address}&format=json"
  end

  def self.get_app_details(appid)
    "https://store.steampowered.com/api/appdetails/?appids=#{appid}"
  end

  def self.get_members_list(steamid)
    "https://steamcommunity.com/gid/#{steamid}/memberslistxml/?xml=1"
  end
end
