class Group < ApplicationRecord
  require 'open-uri'

  def Group.auto_add(url)
  		if url.blank?
  			return "Please enter a URL"
  		end

      begin
        html = open(url)
        page = Nokogiri::HTML(html.read)
      rescue => e
        return "Unable to load URL #{url}"
      end

      if !page.blank?
		    name = page.css('title').text.strip
		    name.slice!("Steam Community :: Group :: ")

				if id = page.xpath("//div[contains(@class,'joinchat_bg')]")
				  steamid = id[0]['onclick']
				  steamid.slice!("window.location='steam://friends/joinchat/")
				  steamid.slice!("'")
				end

				group = Group.where(steamid: steamid).first_or_create
				group.update_attributes(
				  :name		=> name,
				  :url		=> url
				)

				return "Added #{name}"
      end
  end
end
