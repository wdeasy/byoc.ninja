# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'identify'#, callback_url: ENV["DISCORD_CALLBACK_URL"]
  provider :steam, ENV["STEAM_WEB_API_KEY"]
end
