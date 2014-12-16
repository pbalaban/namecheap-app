namespace :cron do
  desc 'Start daily task at 4:00AM EST'
  task daily_work: :environment do
    DomainMarketplaceWorker.perform_async
  end
end
