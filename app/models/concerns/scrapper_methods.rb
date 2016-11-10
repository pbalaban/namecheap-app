require 'thread/pool'

module ScrapperMethods
  extend ActiveSupport::Concern

  included do
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
