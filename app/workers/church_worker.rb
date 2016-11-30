require 'open-uri'

class ChurchWorker
  include Constants
  include Exceptions
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :often

  def perform church_id
    Church.find(church_id).fetch_emails
  end
end
