RailsConfig.setup do |config|
  config.const_name = "Settings"
  config.use_env = Rails.env.production?
end
