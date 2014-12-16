namespace :cleanup do
  desc 'Mark closed domains as inactive'
  task set_domains_inactive: :environment do
    #TODO: implement it after active column will added
  end

  desc 'Reimport all domains'
  task reimport_domains: :environment do
    Domain.destroy_all
    DomainMarketplaceWorker.perform_async
  end
end
