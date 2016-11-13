require 'thread/pool'

module ScrapperMethods
  extend ActiveSupport::Concern
  VALID_EMAIL_REGEX = /[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+/i

  included do
  end

  def fetch_emails
    return if self.website.blank? || self.emails.present?
    result = {}

    Rails.logger.info "current-remote_id=#{self.remote_id} started"

    begin
      Timeout.timeout(60) do
        url = RestClient.get(self.website).request.redacted_uri.to_s
        user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1'

        Anemone.crawl(url, depth_limit: 1, accept_cookies: true, user_agent: user_agent) do |anemone|
          anemone.on_every_page do |page|
            p page.url
            origin_path = page.url.path

            page.body.split("\n").each do |row|
              begin
                encoded = row.to_s.encode('UTF-8',
                  invalid: :replace, undef: :replace, replace: '?'
                )
                decoded = HTMLEntities.new.decode(encoded)
                email = (decoded.match(VALID_EMAIL_REGEX) || [])[0]

                next row if email.to_s.match(/\d+@.*/)
              rescue => e
                Rails.logger.warn "#{('|' * 100)}---#{remote_id}"
                Rails.logger.warn e
                next row
              end

              if email
                result[email] ||= { count: 0, origin: origin_path }
                result[email][:count] += 1
              end
            end
          end
        end
      end
    rescue => e
      Rails.logger.warn "#{('=' * 100)}---#{remote_id}"
      Rails.logger.warn e
    ensure
      Rails.logger.info "current-remote_id=#{self.remote_id} finished. #{result.size} results for #{self.website.to_s}"
      self.update(emails: result)
    end
  end

  module ClassMethods
    def check_country
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

    def start(range)
      range.to_a.each do |id|
        do_process(id)
      end
    end

    def do_process(id)
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

    def fetch_html(id)
      url = "http://www.thecatholicdirectory.com/directory.cfm?fuseaction=display_site_info&siteid=#{id}"
      Nokogiri::HTML(RestClient.get(url))
    end
    # Church.start_with_threads(205_000, 1000, 5) - stopped
    # Church.start_with_threads(140_000, 1000, 5) - stopped
    # Church.start_with_threads(20_000, 1000, 5) - stopped

    def start_with_threads(start, step, thread_count)
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

    def start_array_with_threads(array, thread_count)
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
  end
end
