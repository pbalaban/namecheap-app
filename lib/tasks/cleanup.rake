namespace :cleanup do
  desc 'Reimport all domains'
  task reimport_domains: :environment do
    Domain.delete_all
    Category.destroy_all
    DomainMarketplaceWorker.perform_async
  end
end
