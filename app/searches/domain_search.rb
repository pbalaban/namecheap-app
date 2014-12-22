class DomainSearch < Searchlight::Search
  search_on Domain.active.includes(:categories).order(:closing_on)
  searches :tld

  def tld
    Array(super) & self.all_tld
  end

  def search_tld
    search.where(tld: tld)
  end

  def all_tld
    top_items = %w(com net org)
    @all_tld ||= Domain.active.distinct.pluck(:tld).sort_by do |e|
      top_items.index(e) || top_items.size
    end
  end
end
