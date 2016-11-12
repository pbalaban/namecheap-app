class MainEmailDetector
  #NOTE: order of keys important! See RANK_ONLY_ONCE
  RATING_TABLE = {
    from_contact_pages: 3,
    from_home_pages: 2,
    mostly_found: 3,
    found_above_the_average: 2,
    contact_person_matched: 4,
    ends_with_the_website_domain: 3,
    starts_with_keyword: 4
  }
  RANK_ONLY_ONCE = {
    from_home_pages: :from_contact_pages,
    found_above_the_average: :mostly_found
  }
  WORD_WITH_MORE_THAN_2_CHARS = /\A\w{2,}\Z/
  POPULAR_KEYWORDS = %w(info webmaster contact secretary admin office)
  CONTACT_PAGES = %w(contact about staff)
  COUNT = 'count'.freeze
  ORIGIN = 'origin'.freeze

  def initialize(church)
    @emails = church.emails
    @contact = church.contact
    @website = church.website
    @rating = @emails.each_with_object({}) { |(e, _), memo| memo[e] = 0 }
    @debug = @emails.each_with_object({}) { |(e, _), memo| memo[e] = [] }
  end

  attr_reader :contact, :emails, :website, :rating, :debug

  def rank_all
    RATING_TABLE.each_key { |name| send(name) }
  end

  def winner
    return :none if self.emails.blank?

    rank_all
    self.rating.max_by { |e, points| points }.first
  end

  private
  def from_contact_pages
    rank_by_email_attrs :from_contact_pages do |_, origin|
      contact_pages_inside?(origin)
    end
  end

  def from_home_pages
    rank_by_email_attrs :from_home_pages do |_, origin|
      /\//i =~ origin
    end
  end

  def mostly_found
    email = self.emails.max_by { |email, attrs| attrs[COUNT] }.first
    update_rank(email, :mostly_found)
  end

  def found_above_the_average
    avg = self.emails.sum { |_, attrs| attrs[COUNT] } / self.emails.size
    rank_by_email_attrs(:found_above_the_average) { |count, _| count >= avg }
  end

  def ends_with_the_website_domain
    rank_by_email_parts :ends_with_the_website_domain do |_, email_domain|
      email_domain == website_domain
    end
  end

  def starts_with_keyword
    rank_by_email_parts :starts_with_keyword do |email_prefix, _|
      email_prefix.in?(POPULAR_KEYWORDS)
    end
  end

  def contact_person_matched
    rank_by_email_parts :contact_person_matched do |email_prefix, _|
      contact_parts_include?(email_prefix)
    end
  end

  def rank_by_email_parts(rank_type, &condition)
    rank_each_email(rank_type) do |email, attrs|
      condition.call *email.split(/@/)
    end
  end

  def rank_by_email_attrs(rank_type, &condition)
    rank_each_email(rank_type) do |email, attrs|
      condition.call *attrs.slice(COUNT, ORIGIN).values
    end
  end

  def rank_each_email(rank_type, &handler)
    self.emails.each do |email, attrs|
      update_rank(email, rank_type) if handler.call(email, attrs)
    end
  end

  def update_rank(email, type)
    return unless email
    return if rank_only_once?(email, type)

    @debug[email] << type
    @rating[email] += RATING_TABLE[type].to_i
  end

  def contact_parts
    self.contact.to_s.split(/\s+/).select { |w| WORD_WITH_MORE_THAN_2_CHARS =~ w }
  end

  def contact_parts_include?(value)
    contact_parts.any? { |part| /#{part}/i =~ value }
  end

  def website_domain
    URI.parse(self.website).host.gsub(/www./, '') rescue nil
  end

  def contact_pages_inside?(value)
    CONTACT_PAGES.any? { |page| /#{page}/i =~ value }
  end

  def rank_only_once?(email, type)
    @debug[email].include?(RANK_ONLY_ONCE[type])
  end
end
