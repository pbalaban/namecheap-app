source 'https://rubygems.org'

ruby '2.1.5'

gem 'rails', '4.2.5'
gem 'pg'

gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 4.0.5'
gem 'coffee-rails', '~> 4.0.0'
gem 'haml-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ujs'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-font-awesome'
  gem 'rails-assets-seiyria-bootstrap-slider'
end

gem 'nokogiri'
gem 'rails_config'
gem 'sidekiq', '~> 3.0'
gem 'sinatra', '>= 1.3.0', require: nil ## Sidekiq monitor use sinatra
gem 'exception_notification'
gem 'timeliness'
gem 'mailgun_rails'
gem 'kaminari'
gem 'searchlight'
gem 'thread'
gem 'anemone'
gem 'htmlentities'

gem 'whenever', require: false

group :production, :staging do
  gem 'unicorn'
end

group :development do
  gem 'unicorn-rails'

  gem 'capistrano', '~> 3.3.0'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano3-unicorn'

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
