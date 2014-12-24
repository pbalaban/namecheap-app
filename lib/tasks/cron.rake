namespace :cron do
  desc 'Start daily task at 4:00AM EST'
  task daily: :environment do
    Domain.closed.destroy_all
    4.times do |i|
      DomainMarketplaceWorker.perform_async(min_price: i*50, max_price: i*50+50)
      sleep 60*5
    end

    5.times do |i|
      DomainMarketplaceWorker.perform_async(min_price: 200+i*10, max_price: 200+i*10+10)
      sleep 60*5
    end
  end

  desc 'Every ten minutes'
  task every_ten_minutes: :environment do
  end
end
