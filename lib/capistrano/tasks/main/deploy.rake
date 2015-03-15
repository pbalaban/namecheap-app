namespace :deploy do
  after :deploy, 'sidekiq:restart'
end
