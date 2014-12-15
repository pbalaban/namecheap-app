class DomainsController < ApplicationController
  def index
    @domains = Domain.all
  end
end
