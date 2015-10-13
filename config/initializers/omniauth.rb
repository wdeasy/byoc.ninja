# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :steam, ENV["STEAM_WEB_API_KEY"]
end
