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
end
