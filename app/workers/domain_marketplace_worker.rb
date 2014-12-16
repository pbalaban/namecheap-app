require 'open-uri'

class DomainMarketplaceWorker
  include Constants
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    1.upto(50) do |current_page|
      listings(current_page).each do |listing|
        attrs = domain_attributes(listing)
        Domain.find_by(name: attrs[:name]) || Domain.create(attrs)
        # DomainListingInfoWorker.perform_async(domain.id) unless domain.active?
      end
    end
  end

  private
  def listings current_page
    document = Nokogiri::HTML(open([BASE_HOST, MARKETPLACE_PATH].join.gsub('%PAGE%', current_page.to_s)))
    document.css(LISTING_ENTRY_SELECTOR)
  end

  def domain_attributes listing_element
    name_element = listing_element.css(LISTING_NAME_SELECTOR)
    price_element = listing_element.css(LISTING_PRICE_SELECTOR)
    closing_on_element = listing_element.css(LISTING_CLOSING_ON_SELECTOR)

    {
      name: name_element.text.strip,
      listing_url: [BASE_HOST, name_element.attr('href').value].join,
      closing_on: Timeliness.parse(closing_on_element.first.next.text.strip, format: 'mmm dd, yyyy') || 1.hour.since,
      price: price_element.text.remove_dollar,
      active: true
    }
  end
end
