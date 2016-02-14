class Group < ActiveRecord::Base
  require 'open-uri'	

  def Group.auto_add(url)
    html = open(url) 
    page = Nokogiri::HTML(html.read)

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
  end 
end