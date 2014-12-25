class DomainsController < ApplicationController
  def index
    @search      = DomainSearch.new(search_params)

    respond_to do |format|
      format.html do
        @total_count = @search.search.count
        @filtered_count = @search.results.count
        @last_updated = Domain.maximum(:updated_at).in_time_zone('Pacific Time (US & Canada)')
        @domains = @search.results.page params[:page]
      end
      format.csv do
        filename  = "domains-#{DateTime.current.strftime('%b-%d-%Y-%I-%M%p')}"
        file_path = @search.results.generate_csv_file
        send_file file_path,
          filename: "#{filename}.csv",
          type: 'text/csv; charset=UTF-8; header=present',
          disposition: "attachment"
      end
    end
  end

  private
  def search_params
    begin
      params.require(:domain_search).permit({ tld: [] },
        :order_dir, :order_attr, :query, :price
      )
    rescue ActionController::ParameterMissing
      {}
    end
  end
end
