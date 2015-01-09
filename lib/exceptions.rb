module Exceptions
  class ExceededLastPage < StandardError
    attr_reader :params

    def initialize params
      @params = params
    end

    def message
      "arguments: #{self.params}"
    end
  end

  class ListingUrlBlank < StandardError
    attr_reader :domain_id

    def initialize domain_id
      @domain_id = domain_id
    end

    def message
      "Listing url blank for domain_id: #{self.domain_id}"
    end
  end
end
