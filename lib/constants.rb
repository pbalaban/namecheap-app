module Constants
  ## URLs
  BASE_HOST = 'https://www.namecheap.com'
  MARKETPLACE_PATH = '/domains/marketplace/buy-domains.aspx'

  ## Selectors
  LISTING_DATES_SELECTOR = 'table.default-table tbody td'
  LISTING_ENTRY_SELECTOR = '.module.marketplace li.group'
  LISTING_NAME_SELECTOR  =  'div.first > strong > a'
  LISTING_PRICE_SELECTOR =  '.price'

  ## Other
  LISTING_DATES = %i[listed_on closing_on expires_on]
end
