class Domain < ActiveRecord::Base
  def get_extra_info!
    self.update MarketplaceScrapper::listing_info(self.listing_url)
  end
end
