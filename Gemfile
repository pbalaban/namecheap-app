source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.5'

gem 'rails', '4.1.8'
gem 'pg'

gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 4.0.5'
gem 'coffee-rails', '~> 4.0.0'
gem 'haml-rails'

gem 'rails-assets-jquery'
gem 'rails-assets-jquery-ujs'
gem 'rails-assets-bootstrap-sass-official'
gem 'rails-assets-font-awesome'

gem 'nokogiri'
gem 'rails_config'
gem 'sidekiq', '~> 3.0'
gem 'sinatra', '>= 1.3.0', require: nil ## Sidekiq monitor use sinatra
gem 'exception_notification'
gem 'timeliness'
gem 'mailgun_rails'
gem 'kaminari'

group :production do
  gem 'unicorn'
end

group :development do
  gem 'unicorn-rails'

  gem 'guard-sidekiq', require: false
  gem 'guard-rails', require: false
  gem 'guard-bundler', require: false
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-nav'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end
