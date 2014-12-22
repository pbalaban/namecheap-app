require 'sidekiq/web'

Rails.application.routes.draw do
  ## TODO: secure with devise or http auth
  mount Sidekiq::Web => '/sidekiq'

  get :domains, to: 'domains#index', constraints: { format: /(csv)/ }
  root 'domains#index'
end
