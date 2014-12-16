class Domain < ActiveRecord::Base
  ## Scopes
  scope :opened, ->{ where("closing_on >= :now", now: DateTime.current) }
  scope :closed, ->{ where("closing_on < :now", now: DateTime.current) }
  scope :active, ->{ opened.where(active: true) }
  scope :inactive, ->{ where active: false }

  def closed?
    self.closing_on.past?
  end
end
