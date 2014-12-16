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

gem 'nokogiri'
gem "rails_config"
gem 'sidekiq', '~> 3.0'
gem 'exception_notification'
gem 'timeliness'

gem "foreman"
group :production, :staging do
  gem "unicorn"
  gem "rails_12factor"
  gem "rails_stdout_logging"
  gem "rails_serve_static_assets"
end

group :development, :test do
  gem 'spring'
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end
