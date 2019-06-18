class SteamWebApi < ApplicationRecord
  def SteamWebApi.get_key
    steam_key = SteamWebApi.first

    if Time.now.day == steam_key.updated_at.day
      steam_key.update_attributes(
        :calls  => steam_key.calls+1
      )
    else
      puts "Total number of api calls for #{1.day.ago}: #{steam_key.calls}"

      steam_key.update_attributes(
        :calls  => 1
      )
    end

    return steam_key.key
  end

  def self.get_json(url)
    parsed = nil

    begin
      parsed = JSON.parse(open(url).read)
    rescue => e
      puts "JSON failed to parse #{url}"
      puts e.message
    end

    return parsed
  end

  def self.get_xml(url)
    parsed = nil

    begin
      parsed = Nokogiri::XML(open(url))
    rescue => e
      puts "Nokogiri failed to open XML #{url}"
      puts e.message
    end

    return parsed
  end

  def self.get_html(url)
    page = nil

    begin
      html = open(url)
      page = Nokogiri::HTML(html.read)
    rescue => e
      puts "Nokogiri failed to open HTML #{url}"
    end

    return page
  end
end
