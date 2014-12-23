class DomainsController < ApplicationController
  def index
    @search      = DomainSearch.new(search_params)
    @total_count = @search.search.count

    respond_to do |format|
      format.html do
        @filtered_count = @search.results.count
        @domains = @search.results.page params[:page]
      end
      format.csv do
        filename  = "domains-#{DateTime.current.strftime('%b-%d-%Y-%I-%M%p')}"
        file_path = @search.results.generate_csv_file
        send_file file_path,
          type: 'text/csv; charset=UTF-8; header=present',
          disposition: "attachment;filename='#{filename}.csv'"
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
