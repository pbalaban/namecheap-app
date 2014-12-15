require 'open-uri'

module MarketplaceScrapper
  def self.run
    document = Nokogiri::HTML(open("https://www.namecheap.com/domains/marketplace/buy-domains.aspx"))

    listings = document.css('.module.marketplace li.group')
    domains = listings.each_with_object([]) do |listing, memo|
      name_link = listing.css('div.first > strong > a')
      domain_attrs = {}
      domain_attrs[:name] = name_link.text.strip
      domain_attrs[:listing_url] = "https://www.namecheap.com#{name_link.attr('href').value}"
      domain_attrs[:closing_on] = DateTime.parse(listing.css('.closing-on').text.strip) rescue DateTime.current
      domain_attrs[:price] = listing.css('.price').text.strip.gsub(/\$/, '')
      memo << domain_attrs
    end

    Domain.create(domains)

    # document
  end

  def self.listing_info url
    document = Nokogiri::HTML(open(url))
    dates = document.css('table.default-table tbody td')

    return {} if dates.blank?

    {
      listed_on: parse_date(dates[0]),
      closing_on: parse_date(dates[1]),
      expires_on: parse_date(dates[2])
    }
  end

  def self.parse_date nokogiri_el
    return nil if nokogiri_el.blank?
    DateTime.strptime("#{nokogiri_el.text.gsub(/\s{2,}/, ' ')} -05", "%b %d, %Y %I:%M %p %Z")
  end
end
