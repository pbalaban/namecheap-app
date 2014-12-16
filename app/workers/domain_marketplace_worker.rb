require 'open-uri'

class DomainMarketplaceWorker
  include Constants
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    listings.each do |listing|
      attrs = domain_attributes(listing)
      domain = Domain.find_by(name: attrs[:name]) || Domain.create(attrs)
      DomainListingInfoWorker.perform_async(domain.id) unless domain.active?
    end
  end

  private
  def document
    Nokogiri::HTML(open([BASE_HOST, MARKETPLACE_PATH].join))
  end

  def listings
    document.css(LISTING_ENTRY_SELECTOR)
  end

  def domain_attributes listing_element
    name_element = listing_element.css(LISTING_NAME_SELECTOR)
    price_element = listing_element.css(LISTING_PRICE_SELECTOR)

    {
      name: name_element.text.strip,
      listing_url: [BASE_HOST, name_element.attr('href').value].join,
      price: price_element.text.remove_dollar
    }
  end
end
