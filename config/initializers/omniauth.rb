# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'identify ', prompt: 'none'
  provider :steam, ENV["STEAM_WEB_API_KEY"]
  provider :bnet, ENV['BNET_KEY'], ENV['BNET_SECRET']
  provider :twitch, ENV["TWITCH_CLIENT_ID"], ENV["TWITCH_CLIENT_SECRET"]
end
