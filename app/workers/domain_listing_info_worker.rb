require 'open-uri'

class DomainListingInfoWorker
  include Constants
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform domain_id
    @domain = Domain.find(domain_id)
    return if @domain.active?

    @domain.update(listing_info)
  end

  private
  def document
    Nokogiri::HTML(open(@domain.listing_url))
  end

  def dates
    @dates ||= document.css(LISTING_DATES_SELECTOR)
  end

  def listing_info
    return {} if dates.blank?

    LISTING_DATES.each.with_index.with_object(active: true) do |(date_name, idx), memo|
      memo[date_name] = Timeliness.parse(dates[idx].text.to_s.sanitize_spaces)
    end
  end
end
