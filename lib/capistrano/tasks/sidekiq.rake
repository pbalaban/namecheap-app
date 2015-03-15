namespace :sidekiq do
  desc 'Restart sidekiq'
  task :restart do
    on roles(:app) do
      execute :sudo, 'restart sidekiq-manager'
    end
  end
end
