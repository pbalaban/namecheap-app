module Constants
  ## URLs
  BASE_HOST = 'https://www.namecheap.com'
  MARKETPLACE_BY_USER_URL = "#{BASE_HOST}/domains/marketplace/buy-domains.aspx?sellerusername=%ID%"
  MARKETPLACE_BY_CATEGORY_URL = "#{BASE_HOST}/domains/marketplace/buy-domains.aspx?CategoryId=%ID%"
  MARKETPLACE_INDEX_URL = "#{BASE_HOST}/domains/marketplace/buy-domains.aspx"
  MARKETPLACE_URL = %{#{BASE_HOST}/domains/marketplace/buy-domains.aspx
    ?page=%PAGE%
    &size=100
    &SortExpression=Expiry_ASC
    &priceRange=%MINPRICERANGE%:%MAXPRICERANGE%
    &keyword=%KEYWORD%
  }.gsub(/\s+/, '')

  ## Selectors
  INDEX_ENTRY_SELECTOR      = '.module.marketplace li.group'
  INDEX_NAME_SELECTOR       =  'div.first > strong > a'
  INDEX_CLOSING_ON_SELECTOR =  '.closing-on'
  INDEX_PRICE_SELECTOR      =  '.price'
  INDEX_NEXT_PAGE_SELECTOR  =  '.pagination a.next'
  SHOW_DATES_SELECTOR       = 'table.default-table tbody td'
  SHOW_CATEGORIES_SELECTOR  = '.marketplace-info li:eq(1) a'
  SHOW_USER_SELECTOR        = '.marketplace-info li:eq(2) a'
  CATEGORY_LABELS_SELECTOR  = '#filters-modal .domain-filter-form label'

  ## Other
  LISTING_DATES = %i[listed_on closing_on expires_on]
end
