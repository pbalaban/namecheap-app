Sidekiq.configure_client do |config|
  config.redis = Settings.redis.client.to_h
end

Sidekiq.configure_server do |config|
  config.redis = Settings.redis.server.to_h
end
