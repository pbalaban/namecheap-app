class Church < ActiveRecord::Base
  include ScrapperMethods

  DETAILS_ATTRS = %i(street city state country diocese rite language contact website phone fax)

  serialize :details, HashSerializer
  serialize :emails, JSON
  store_accessor :details, *DETAILS_ATTRS

  validates :remote_id, uniqueness: true

  scope :with_website, -> { where.not("details -> 'website' ? ''") }
  scope :search_details_for, -> (key, value) do
    where('details -> :key ? :value', key: key, value: value)
  end
  scope :ordered, -> { order(:remote_id) }


  def self.generate_csv(churches)
    path = Tempfile.new('namecheap_app')

    CSV.open(path, "wb") do |csv|
      csv << Church.csv_header
      churches.each{ |d| csv << d.to_csv }
    end

    FileUtils.cp(path, '/home/peter/Desktop/')
  end

  def self.csv_header
    %w(
      Church-ID Church-Name Street-Name Town/City State/County Country Diocese Rite
      Language ContactName Website Phone-No. Fax-No Main-Email All-Emails
    )
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
    self.us? ? self.locations[-2] : ''
  end

  def detect_diocese
    candidate = self.nok_html.css('#parish_info > a').detect do |link|
      link.attr(:href).match(/fuseaction=display_site_info/)
    end
    candidate ? candidate.text.strip : ''
  end

  def detect_phone
    self.nok_html.css(
      "#parish_info span[itemprop='telephone']"
    ).text.to_s.gsub(/phone\:\s+/i, '')
  end

  def main_email
    MainEmailDetector.new(self).winner
  end

  def all_emails
    self.emails.sort_by do |email, attrs|
      attrs['count'.freeze]
    end.reverse.map do |email, attrs|
      email_row(email, attrs['count'.freeze], attrs['origin'.freeze])
    end#.join("\n")
  end

  def to_csv
    self.attributes.slice('remote_id'.freeze, 'title'.freeze).values +
      self.details.slice(*DETAILS_ATTRS).values +
      [self.main_email] + self.all_emails
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
        website: self.nok_html.css("#parish_info a[itemprop='url']").attr(:href),
        phone: self.detect_phone,
        fax: self.nok_html.css("#parish_info span[itemprop='faxNumber']").text
      )
    rescue => e
      p '*************************'
      p e
      p self.remote_id
    end
  end

  def email_row(email, count, origin)
    "#{email} (found: #{count} times and firstly met: #{origin})"
  end
end
