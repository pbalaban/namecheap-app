require 'thread/pool'

class Church < ActiveRecord::Base
  VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+/i

  serialize :details, HashSerializer
  store_accessor :details, :street, :city, :state, :country, :diocese, :rite, :language, :email, :contact, :website, :phone, :fax

  validates :remote_id, uniqueness: true

  scope :search_details_for, -> (key, value) do
    where('details -> :key ? :value', key: key, value: value)
  end

  def self.check_country
    ActiveRecord::Base.logger = nil
    country = 'http://www.thecatholicdirectory.com/directory.cfm?fuseaction=show_country&country=MX'

    begin
      count = 0
      doc = Nokogiri::HTML(RestClient.get(country))
      doc.css('a').select do |l|
        l.attr(:href).match(/fuseaction=search_directory/)
      end.each do |l|
        p l.text
        doc2 = Nokogiri::HTML(RestClient.get("http://www.thecatholicdirectory.com/#{l.attr(:href)}"))
        doc2.css('a').select do |l2|
          l2.attr(:href).match(/fuseaction=display_site_info/)
        end.each do |l2|
          id = l2.attr(:href).match(/siteid=(\d+)/)[1]

          unless Church.find_by(remote_id: id)
            p '*******************exception******************'
            p id
          end
          count += 1
        end
      end

      p count
    rescue => e
      p '*******************exception******************'
      p e
    end
  end

  def self.start(range)
    range.to_a.each do |id|
      do_process(id)
    end
  end

  def self.do_process(id)
    p "---#{id}" if id%100 == 0
    return if Church.exists?(remote_id: id)

    begin
      document = fetch_html(id)
      return id if document.css('#parish_info').blank?
    rescue => e
      p '*******************exception******************'
      p e
      p id
      return id
    end

    c = Church.new(
      remote_id: id,
      html: document.css('#parish_info').to_html,
      title: document.css('.title').text.strip,
      breadcrumb: document.css('#breadcrumb').text
    )
    p c.remote_id if c.save
  end

  def self.fetch_html(id)
    url = "http://www.thecatholicdirectory.com/directory.cfm?fuseaction=display_site_info&siteid=#{id}"
    Nokogiri::HTML(RestClient.get(url))
  end
  # (50701..70000)

  # Church.start(230000..330000) - 0
  # Church.start(45_000..61_000) - now
  # Church.start(160_000..200_000) - now
  # Church.start(61_000..85_000) - todo
  # Church.start(109_000..150_000) - todo

  # Church.start_with_threads(30_000, 1000, 5) - down
  # Church.start_with_threads(135_000, 1000, 5) - upto 150
  # Church.start_with_threads(80_000, 1000, 5) - upto 85
  # Church.start_with_threads(145_000, 1000, 5) - down to 110

  # Church.start(147640..200000)

  # ids = Church.pluck(:remote_id) and e = nil
  # Church.start((0..170_000).to_a - ids)

  def self.start_pack

  end

  def self.start_with_threads(start, step, thread_count)
    ActiveRecord::Base.logger = nil

    pool = Thread.pool(thread_count)

    thread_count.times do |i|
      pool.process do
        0.upto(step - 1) do |j|
          do_process(start+step*i + j)
        end
      end
    end

    pool.shutdown
  end

  def self.start_array_with_threads(array, thread_count)
    ActiveRecord::Base.logger = nil

    pool = Thread.pool(thread_count)

    array.in_groups(thread_count).each do |i|
      pool.process do
        i.each do |j|
          do_process(j)
        end
      end
    end

    pool.shutdown
  end


  def self.generate_csv(churches)
    path = Tempfile.new('namecheap_app')

    CSV.open(path, "wb") do |csv|
      csv << Church.csv_header
      churches.each{ |d| csv << d.to_csv }
    end

    FileUtils.cp(path, '/home/peter/tmp/')
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
    begin
      [
        self.remote_id,
        self.title,
        self.address.children.first.text.strip,
        self.detect_city,
        self.detect_state,
        self.detect_country_or_state,
        self.detect_diocese,
        self.nok_html.css("#parish_info span[itemprop='rite']").text,
        self.nok_html.css("#parish_info span[itemprop='language']").text,
        self.nok_html.css("#parish_info span[itemprop='contactPoints']").text,
        self.nok_html.css("#parish_info a[itemprop='url']").text,
        :None,
        self.nok_html.css("#parish_info span[itemprop='telephone']").text,
        self.nok_html.css("#parish_info span[itemprop='faxNumber']").text,
      ]
    rescue
      [self.remote_id]
    end
  end

  # %w(Street-Name Town/City State/County Country Diocese Rite Language ContactName Website Email Phone-No. Fax-No)
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
