class DomainMarketplaceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    raise 'I am failed DomainMarketplaceWorker'
  end
end
