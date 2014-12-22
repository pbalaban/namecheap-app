class DomainsController < ApplicationController
  def index
    @domains = Domain.active.order(:closing_on)

    respond_to do |format|
      format.html do
        @domains = @domains.page params[:page]
      end
      format.csv do
        filename  = "domains-#{DateTime.current.strftime('%b-%d-%Y-%I-%M%p')}"
        file_path = @domains.generate_csv_file
        send_file file_path,
          type: 'text/csv; charset=UTF-8; header=present',
          disposition: "attachment;filename='#{filename}.csv'"
      end
    end
  end
end
