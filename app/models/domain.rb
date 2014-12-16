class Domain < ActiveRecord::Base
  # ## Callbacks
  before_save :set_tld

  ## Scopes
  scope :opened, ->{ where("closing_on >= :now", now: DateTime.current) }
  scope :closed, ->{ where("closing_on < :now", now: DateTime.current) }
  scope :active, ->{ opened.where(active: true) }
  scope :inactive, ->{ where active: false }

  def closed?
    self.closing_on.past?
  end

  private
  def set_tld
    self.tld = self.name.to_s.split('.')[1..-1].join('.')
  end
end
