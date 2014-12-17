module Constants
  ## URLs
  BASE_HOST = 'https://www.namecheap.com'
  MARKETPLACE_INDEX_PATH = '/domains/marketplace/buy-domains.aspx'
  MARKETPLACE_PATH = '/domains/marketplace/buy-domains.aspx?page=%PAGE%&size=100&SortExpression=Expiry_ASC'

  ## Selectors
  LISTING_DATES_SELECTOR      = 'table.default-table tbody td'
  LISTING_ENTRY_SELECTOR      = '.module.marketplace li.group'
  LISTING_NAME_SELECTOR       =  'div.first > strong > a'
  LISTING_CLOSING_ON_SELECTOR =  '.closing-on'
  LISTING_PRICE_SELECTOR      =  '.price'
  CATEGORY_LABELS_SELECTOR    = '#filters-modal .domain-filter-form label'

  ## Other
  LISTING_DATES = %i[listed_on closing_on expires_on]
end
