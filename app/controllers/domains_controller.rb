class DomainsController < ApplicationController
  def index
    @domains = Domain.active.load
  end
end
