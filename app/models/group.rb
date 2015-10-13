class Group < ActiveRecord::Base
  self.primary_key = :groupid64
  require 'open-uri'	

  def Group.auto_add(url)
    html = open(url) 
    page = Nokogiri::HTML(html.read)

    name = page.css('title').text.strip
    name.slice!("Steam Community :: Group :: ")

	if id = page.xpath("//div[contains(@class,'joinchat_bg')]")
	  groupid64 = id[0]['onclick']
	  groupid64.slice!("window.location='steam://friends/joinchat/")
	  groupid64.slice!("'")
	end

	group = Group.where(groupid64: groupid64).first_or_create
	group.update_attributes(
	  :name		=> name,
	  :url		=> url
	)
  end 
end