require 'sidekiq/web'

Rails.application.routes.draw do
  ## TODO: secure with devise or http auth
  mount Sidekiq::Web => '/sidekiq'

  root 'domains#index'
end
