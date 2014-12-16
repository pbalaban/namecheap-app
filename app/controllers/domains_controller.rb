class DomainsController < ApplicationController
  def index
    @domains = Domain.order(:closing_on).page params[:page]
  end
end
