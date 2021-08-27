class Group < ApplicationRecord
  require 'open-uri'

  def Group.auto_add(url)
    success = false
    message = nil

		if url.blank?
			message = "Please enter a URL"
      return {success: success, message: message}
		end

    page =  SteamWebApi.get_html(url)
    if page.blank?
      message = "Error reading URL"
      return {success: success, message: message}
		end

    name = page.css('title').text.strip
    name.slice!("Steam Community :: Group :: ")

    if id = page.xpath("//div[contains(@class,'joinchat_bg')]")
      steamid = id[0]['onclick'].delete('^0-9')
    else
      message = "Could not read Steam ID"
      return {success: success, message: message}
    end

    group = Group.where(steamid: steamid).first_or_create
    group.update(
      :name		=> name,
      :url		=> url
    )

    if group.present? && group.name.present?
      success = true
      message = "Added #{name}"
      return {success: success, message: message}
    else
      message = "Could not save group."
      return {success: success, message: message}
    end
  end
end
