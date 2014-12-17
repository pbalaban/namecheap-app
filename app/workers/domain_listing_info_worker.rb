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
    @dates ||= document.css(SHOW_DATES_SELECTOR)
  end

  def listing_info
    return {} if dates.blank?

    remote_user_element = document.css(SHOW_USER_SELECTOR)
    categories_element  = document.css(SHOW_CATEGORIES_SELECTOR)
    category_ids        = categories_element.map do |element|
      Category.where(name: element.text).
        find_or_create_by(remote_id: element.attr('href')[/\d+/]).try(:id)
    end
    attrs = {
      active: true,
      remote_user: remote_user_element.text,
      category_ids: category_ids
    }

    LISTING_DATES.each.with_index.with_object(attrs) do |(date_name, idx), memo|
      memo[date_name] = Timeliness.parse(dates[idx].text.to_s.sanitize_spaces)
    end
  end
end
