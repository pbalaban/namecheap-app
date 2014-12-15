class DomainMarketplaceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    p 'I am DomainMarketplaceWorker'
  end
end
