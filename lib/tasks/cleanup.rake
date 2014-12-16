namespace :cleanup do
  desc 'Reimport all domains'
  task reimport_domains: :environment do
    Domain.destroy_all
    DomainMarketplaceWorker.perform_async
  end
end
