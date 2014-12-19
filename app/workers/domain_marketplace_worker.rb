require 'open-uri'

class DomainMarketplaceWorker
  include Constants
  include Exceptions
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :market

  def perform opts = {}
    opts.symbolize_keys!.reverse_merge!(
      min_price: nil, max_price: 50, first_page: 1, keyword: nil
    )
    search_params = {
      '%PAGE%' => 1,
      '%MINPRICERANGE%' => opts[:min_price],
      '%MAXPRICERANGE%' => opts[:max_price],
      '%KEYWORD%' => opts[:keyword]
    }

    opts[:first_page].upto(50) do |current_page|
      search_params.merge!('%PAGE%' => current_page)

      url = open(MARKETPLACE_URL.gsub(/%\w*%/, search_params))
      document = Nokogiri::HTML(url)
      listings = document.css(INDEX_ENTRY_SELECTOR)

      document_ids = []
      Domain.transaction do
        listings.each do |listing|
          attrs = domain_attributes(listing)
          document_ids << (Domain.find_by(name: attrs[:name]) || Domain.create(attrs)).id
        end
      end
      document_ids.each{ |id| DomainListingInfoWorker.perform_async(id) }

      return if document.css(INDEX_NEXT_PAGE_SELECTOR).blank?
    end

    raise ExceededLastPage.new(opts)
  end

  private
  def domain_attributes listing_element
    name_element = listing_element.css(INDEX_NAME_SELECTOR)
    price_element = listing_element.css(INDEX_PRICE_SELECTOR)
    closing_on_element = listing_element.css(INDEX_CLOSING_ON_SELECTOR)

    return {} unless name_element.present?

    listing_path = name_element.attr('href').value
    closing_on_text = closing_on_element.first.next.text.strip

    {
      name: name_element.text.strip,
      listing_url: listing_path ? [BASE_HOST, listing_path].join : nil,
      closing_on: Timeliness.parse(closing_on_text) || 1.hour.since,
      price: price_element.text.remove_dollar
    }
  end
end
