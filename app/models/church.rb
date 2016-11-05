class Church < ActiveRecord::Base
  VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+/i

  def self.start(range)
    Pry::Commands.rename_command("nnext", "next")

    range.to_a.each do |id|
      p id if id%20 == 0

      begin
        document = fetch_html(id)
        next id if document.css('#parish_info').blank?
      rescue => e
        p '*******************exception******************'
        p e
        p id
        next id
      end

      Church.create(
        remote_id: id,
        html: document.css('#parish_info').to_html,
        title: document.css('.title').text.strip,
        breadcrumb: document.css('#breadcrumb').text
      )
    end
  end

  def self.fetch_html(id)
    url = "http://www.thecatholicdirectory.com/directory.cfm?fuseaction=display_site_info&siteid=#{id}"
    Nokogiri::HTML(RestClient.get(url))
  end
  # (50701..70000)
  # start(56087..200000)
  # start(147640..200000)

  def self.generate_csv
    churches = Church.all
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

  def country
    self.address.text.match(/\sUS/) ? :USA : self.state_or_country
  end

  def state_or_country
    self.breadcrumb.split(/\s>\s/)[-2]
  end

  def diocese
    diocese_regexp = %r{directory.cfm\?fuseaction=display_site_info\&siteid}
    candidate = self.nok_html.css("#parish_info a").first

    return nil unless candidate.is_a?(Nokogiri::XML::Element)

    candidate.text.strip if candidate.attr(:href).match(diocese_regexp)
  end

  def to_csv
    begin
      [
        self.remote_id,
        self.title,
        self.address.children.first.text.strip,
        self.breadcrumb.split(/\s>\s/).last.strip,
        self.state_or_country,
        self.country,
        self.diocese,
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
end
