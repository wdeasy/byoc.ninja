module GamesHelper
  def store_link(game, text="store link", options={})
  	link_to text, "http://store.steampowered.com/app/#{game.gameid}", options
  end

  def comm_link(game, text="community link", options={})
  	link_to text, "http://steamcommunity.com/app/#{game.gameid}", options
  end

  def full_img(game, options={})
  	image_tag "http://cdn.akamai.steamstatic.com/steam/apps/#{game.gameid}/header.jpg", options
  end
end

