namespace :cron do
  desc 'Start daily task at 4:00AM EST'
  task daily: :environment do
    Domain.closed.update_all(active: false)
    DomainMarketplaceWorker.perform_async
  end

  desc 'Every ten minutes'
  task every_ten_minutes: :environment do
  end
end
