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
end
