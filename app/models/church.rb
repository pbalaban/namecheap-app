class Church < ActiveRecord::Base
  include ScrapperMethods

  VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+/i
  DETAILS_ATTRS = %i(street city state country diocese rite language contact website email phone fax)

  serialize :details, HashSerializer
  store_accessor :details, *DETAILS_ATTRS

  validates :remote_id, uniqueness: true

  scope :search_details_for, -> (key, value) do
    where('details -> :key ? :value', key: key, value: value)
  end

  default_scope -> { order(:remote_id) }


  def self.generate_csv(churches)
    path = Tempfile.new('namecheap_app')

    CSV.open(path, "wb") do |csv|
      csv << Church.csv_header
      churches.each{ |d| csv << d.to_csv }
    end

    FileUtils.cp(path, '/home/peter/Desktop/')
  end

  def self.csv_header
    %w(Church-ID Church-Name Street-Name Town/City State/County Country Diocese Rite Language ContactName Website Email Phone-No. Fax-No)
  end

  def nok_html
    @nok_html ||= Nokogiri::HTML(self.html)
  end

  def email
    self.nok_html.css("#parish_info").text.match(VALID_EMAIL_REGEX)
  end

  def address
    self.nok_html.css("#parish_info span[itemprop='address']")
  end

  def us?
    self.address.text.match(/\sUS/)
  end

  def locations
    self.breadcrumb.split(/\s>\s/)
  end

  def detect_city
    self.locations.last.strip
  end

  def detect_country_or_state
    self.us? ? :USA : self.locations[-2]
  end

  def detect_state
    self.us? ? self.locations[-2] : nil
  end

  def detect_diocese
    candidate = self.nok_html.css('#parish_info > a').detect do |link|
      link.attr(:href).match(/fuseaction=display_site_info/)
    end
    candidate ? candidate.text.strip : nil
  end

  def to_csv
    self.attributes.slice(
      'remote_id'.freeze, 'title'.freeze
    ).values + self.details.slice(*DETAILS_ATTRS).values
  end

  def update_details
    begin
      self.update(
        street: self.address.children.first.text.strip,
        city: self.detect_city,
        state: self.detect_state,
        country: self.detect_country_or_state,
        diocese: self.detect_diocese,
        rite: self.nok_html.css("#parish_info span[itemprop='rite']").text,
        language: self.nok_html.css("#parish_info span[itemprop='language']").text,
        contact: self.nok_html.css("#parish_info span[itemprop='contactPoints']").text,
        website: self.nok_html.css("#parish_info a[itemprop='url']").text,
        email: nil,
        phone: self.nok_html.css("#parish_info span[itemprop='telephone']").text,
        fax: self.nok_html.css("#parish_info span[itemprop='faxNumber']").text
      )
    rescue => e
      p '*************************'
      p e
      p self.remote_id
    end
  end
end
