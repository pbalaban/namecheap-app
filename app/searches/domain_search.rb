class DomainSearch < Searchlight::Search
  search_on ->{ Domain.active.includes(:categories) }
  searches :tld, :query, :price, :order_attr, :order_dir

  def tld
    Array(super) & self.all_tld
  end

  def price
    super || self.default_prices
  end

  def order_attr
    super.in?(%w(closing_on name tld price)) ? super.to_sym : :closing_on
  end

  def order_dir
    super.in?(%w(asc desc)) ? super.to_sym : :asc
  end

  def search_tld
    search.where(tld: tld)
  end

  def search_query
    search.filter_by_query(query)
  end

  def search_price
    range = Range.new(*price.split(','))
    search.filter_by_price(range)
  end

  def search_order_attr
    search.order(order_attr => order_dir)
  end

  def all_tld
    @all_tld ||= Domain.active.distinct.pluck(:tld)
  end

  def min_price
    @min_price ||= Domain.active.minimum(:price).to_f
  end

  def max_price
    @max_price ||= Domain.active.maximum(:price).to_f
  end

  def default_prices
    [self.min_price, self.max_price].join(',')
  end

  def reverse_order_dir_for attr
    self.order_attr.eql?(attr) ? (self.order_dir.eql?(:asc) ? :desc : :asc) : :asc
  end

  def filter_enabled?
    [self.tld, self.query].any?(&:present?) || !self.price.eql?(self.default_prices)
  end
end
