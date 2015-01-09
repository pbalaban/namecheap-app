namespace :cron do
  desc 'Start daily task at 4:00AM EST'
  task daily: :environment do
    Domain.closed.destroy_all

    # Price ranges: 0..50, 50..100, 100..150, 150..200
    4.times do |i|
      DomainMarketplaceWorker.perform_async(min_price: i*50, max_price: i*50+50)
    end

    # Price ranges: 200..210, 210..220, 220..230, 230..240, 240..250
    5.times do |i|
      DomainMarketplaceWorker.perform_async(min_price: 200+i*10, max_price: 200+i*10+10)
    end
  end

  desc 'Every ten minutes'
  task every_ten_minutes: :environment do
  end
end
